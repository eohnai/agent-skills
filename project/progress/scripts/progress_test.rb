# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ProgressTest < Minitest::Test
  SCRIPT = File.expand_path("progress.sh", __dir__)

  def test_counts_tasks_and_skips_blocked_tasks_for_next
    out = board(
      "specs/auth.md" => <<~MD
        - [x] JWT tokens
        - [ ] rate limit login (blocked: waiting for API key)
        - [ ] login form
      MD
    )

    assert_equal ["auth", "in progress", "-", "1", "2", "1", "login form"], row(out, "auth")
    assert_includes out, "- auth: rate limit login (blocked: waiting for API key)"
  end

  def test_derived_statuses
    out = board(
      "specs/fresh.md" => "- [ ] first\n",
      "specs/ticked.md" => "- [x] first\n",
      "specs/stuck.md" => "- [x] first\n- [ ] second (blocked: no access)\n",
      "specs/empty.md" => "# No tasks yet\n"
    )

    assert_equal "not started", row(out, "fresh")[1]
    assert_equal "all ticked", row(out, "ticked")[1]
    assert_equal "blocked (all open tasks)", row(out, "stuck")[1]
    assert_equal "no tasks", row(out, "empty")[1]
  end

  def test_needs_waits_until_the_needed_spec_is_marked_done
    out = board(
      "specs/base.md" => "- [x] only task\n",
      "specs/next.md" => "Needs: base\n\n- [ ] first\n"
    )
    assert_equal "waiting on base", row(out, "next")[1]

    out = board(
      "specs/base.md" => "Status: done\n\n- [x] only task\n",
      "specs/next.md" => "Needs: base\n\n- [ ] first\n"
    )
    assert_equal "not started", row(out, "next")[1]
  end

  def test_needs_accepts_backticks_and_lists_only_unfinished_specs
    out = board(
      "specs/a.md" => "Status: dropped\n\n- [ ] never done\n",
      "specs/c.md" => "**Needs:** `a`, `b`\n\n- [ ] first\n"
    )

    assert_equal "waiting on b", row(out, "c")[1]
  end

  def test_needs_is_ignored_once_work_has_started
    out = board("specs/c.md" => "Needs: missing\n\n- [x] first\n- [ ] second\n")

    assert_equal "in progress", row(out, "c")[1]
  end

  def test_area_folder_groups_its_specs
    out = board(
      "specs/booking/requests.md" => "- [x] one\n- [ ] two (blocked: no key)\n",
      "specs/booking/sessions.md" => "- [ ] three\n"
    )

    assert_equal "0 of 2 specs finished", row(out, "**booking**")[1]
    assert_equal ["requests", "blocked (all open tasks)", "-", "1", "1", "1", "two (blocked: no key)"], row(out, "requests")
    assert_equal "not started", row(out, "sessions")[1]
    assert_includes out, "- booking/requests: two (blocked: no key)"
  end

  def test_needs_finds_a_spec_in_the_same_area_or_by_its_full_id
    out = board(
      "specs/booking/scaffold.md" => "Status: done\n\n- [x] first\n",
      "specs/booking/requests.md" => "Needs: scaffold, matching/scores\n\n- [ ] first\n",
      "specs/matching/scores.md" => "- [ ] first\n"
    )

    assert_equal "waiting on matching/scores", row(out, "requests")[1]
  end

  def test_done_and_dropped_specs_go_on_one_line
    files = {
      "specs/old.md" => "Status: done\n\n- [x] one\n- [x] two\n",
      "specs/cut.md" => "Status: dropped\n\n- [ ] never\n",
      "specs/live.md" => "- [ ] first\n"
    }

    out = board(files)
    assert_nil row(out, "old")
    assert_nil row(out, "cut")
    assert_includes out, "**Done or dropped:** cut (dropped), old (done)."
    assert_equal ["**Total**", "", "", "**2**", "**1**", "**0**", ""], row(out, "**Total**")

    out = board(files, "--all")
    assert_equal "done", row(out, "old")[1]
    assert_equal "dropped", row(out, "cut")[1]
    refute_includes out, "Done or dropped"
  end

  def test_done_with_unticked_tasks_is_not_finished
    out = board(
      "specs/area/odd.md" => "Status: done\n\n- [x] one\n- [ ] two\n",
      "specs/later.md" => "Needs: area/odd\n\n- [ ] first\n",
      "specs/area/area.md" => "# Area\n\n## Specs\n- `odd`: one.\n"
    )

    assert_equal "done (but 1 unticked)", row(out, "odd")[1]
    assert_equal "waiting on area/odd", row(out, "later")[1]
    assert_equal "0 of 1 spec finished", row(out, "**Area**")[1]
    refute_includes out, "Done or dropped"
  end

  def test_closed_specs_leave_open_and_blocked_tasks_out_of_the_total
    out = board(
      "specs/cut.md" => "Status: dropped\n\n- [x] one\n- [ ] two (blocked: no access)\n",
      "specs/live.md" => "- [ ] first\n"
    )

    assert_equal ["**Total**", "", "", "**1**", "**1**", "**0**", ""], row(out, "**Total**")
    refute_includes out, "Blocked tasks"
  end

  def test_specs_heading_can_be_any_level
    out = board(
      "specs/booking/area.md" => "# Booking\n\n### Specs\n- `a`: one.\n",
      "specs/billing/area.md" => "## Specs\n- `b`: one.\n"
    )

    assert_equal "no spec yet", row(out, "a")[1]
    assert_equal "0 of 1 spec finished", row(out, "**billing**")[1]
  end

  def test_due_dates
    out = board(
      "specs/late.md" => "Due: 2000-01-01\n\n- [ ] first\n",
      "specs/shipped.md" => "Due: 2000-01-01\n\n- [x] first\n",
      "specs/vague.md" => "Due: next week\n\n- [ ] first\n"
    )

    assert_match(/\A2000-01-01 \(OVERDUE by \d+ days\)\z/, row(out, "late")[2])
    assert_equal "2000-01-01", row(out, "shipped")[2]
    assert_equal "next week (not a YYYY-MM-DD date)", row(out, "vague")[2]
  end

  BOOKING_AREA = <<~MD
    # Booking

    Owns everything after a client clicks Request.

    ## Specs
    - `scaffold`: skeleton and pipeline.
    - `booking/requests`: a client requests a trainer. Needs: scaffold.
    - `sessions`: either side cancels.

    ## Shared context
    - `not-a-spec`: under another heading
  MD

  def test_board_follows_the_area_files
    out = board(
      "specs/booking/area.md" => BOOKING_AREA,
      "specs/booking/scaffold.md" => "Status: done\n\n- [x] first\n",
      "specs/booking/requests.md" => "- [x] first\n- [ ] second\n",
      "specs/booking/extra.md" => "- [ ] first\n",
      "specs/matching/area.md" => "# Matching\n\n## Specs\n- `scores`: score each trainer.\n",
      "specs/matching/scores.md" => "- [ ] first\n",
      "specs/login.md" => "- [ ] first\n"
    )

    names = out.lines.grep(/\A\| /).map { |l| l.split("|")[1].strip }
    assert_equal(
      ["Spec", "**Booking**", "~~scaffold~~", "requests", "sessions", "extra",
       "**Matching**", "scores", "**No area**", "login", "**Total**"],
      names
    )
    assert_equal "1 of 4 specs finished", row(out, "**Booking**")[1]
    assert_equal "done", row(out, "~~scaffold~~")[1]
    assert_equal "no spec yet", row(out, "sessions")[1]
    assert_nil row(out, "not-a-spec")
    assert_equal "**+1 spec not written yet**", row(out, "**Total**")[1]
  end

  def test_area_with_every_spec_finished_goes_on_one_line
    files = {
      "specs/booking/area.md" => "# Booking\n\n## Specs\n- `a`: one.\n- `b`: two.\n",
      "specs/booking/a.md" => "Status: done\n\n- [x] first\n",
      "specs/booking/b.md" => "Status: dropped\n\n- [ ] first\n"
    }

    out = board(files)
    assert_nil row(out, "**Booking**")
    assert_includes out, "**Done or dropped:** Booking (all 2 specs)."

    out = board(files, "--all")
    assert_equal "2 of 2 specs finished", row(out, "**Booking**")[1]
    assert_equal "dropped", row(out, "~~b~~")[1]
  end

  def test_area_falls_back_to_the_folder_name
    out = board("specs/billing/area.md" => "## Specs\n- `charge`: charge a client.\n")

    assert_equal "0 of 1 spec finished", row(out, "**billing**")[1]
  end

  def test_no_area_heading_without_areas
    out = board("specs/a.md" => "- [ ] first\n")

    refute_includes out, "No area"
  end

  def test_old_roadmaps_get_a_note
    out = board(
      "specs/a.md" => "- [ ] first\n",
      "notes/booking-roadmap.md" => "# Booking roadmap\n\n## Slices\n- `a`: one.\n"
    )

    assert_nil row(out, "**Booking**")
    assert_includes out, "**Old roadmaps:** notes/booking-roadmap.md."
  end

  def test_total_row_without_slices_has_an_empty_cell
    out = board("specs/a.md" => "- [ ] first\n")

    assert_includes out, "| **Total** | | | **0** | **1** | **0** | |"
  end

  def test_owners_table
    out = board("specs/a.md" => "- [ ] one @alex\n- [ ] two @alex (blocked: review)\n- [ ] three @sam\n")

    assert_includes out, "| @alex | 2 | 1 |"
    assert_includes out, "| @sam | 1 | 0 |"
  end

  def test_missing_and_empty_specs_folder
    Dir.mktmpdir("progress-test") do |root|
      assert_equal "No specs/ folder in #{root}\n", run_script(root)

      FileUtils.mkdir_p(File.join(root, "specs"))
      assert_includes run_script(root), "| **Total** | | | **0** | **0** | **0** | |"
    end
  end

  private

  # Writes the files into a temporary records folder and returns the script's output.
  def board(files, *args)
    Dir.mktmpdir("progress-test") do |root|
      files.each do |path, text|
        full = File.join(root, path)
        FileUtils.mkdir_p(File.dirname(full))
        File.write(full, text)
      end
      run_script(root, *args)
    end
  end

  def run_script(root, *args)
    stdout, stderr, status = Open3.capture3("bash", SCRIPT, *args, root)
    assert status.success?, stderr
    stdout
  end

  # The cells of the board row for name, or nil if there is no such row.
  def row(out, name)
    line = out.lines.find { |l| l.start_with?("| #{name} |") }
    line&.chomp&.split("|")&.map(&:strip)&.drop(1)
  end
end
