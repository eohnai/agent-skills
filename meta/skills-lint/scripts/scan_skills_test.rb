# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ScanSkillsTest < Minitest::Test
  SCANNER = File.expand_path("scan_skills.rb", __dir__)

  def test_reports_aligned_names
    result = scan(
      "wayfinder" => {
        name: "wayfinder",
        openai: <<~YAML
          interface:
            display_name: "wayfinder"
            short_description: "Map decision tickets"
          policy:
            allow_implicit_invocation: true
        YAML
      }
    )

    skill = result.fetch("skills").first
    assert_equal "wayfinder", skill.fetch("directory_name")
    assert_equal "wayfinder", skill.fetch("name")
    assert_equal "wayfinder", skill.dig("codex", "display_name")
    assert_equal true, skill.dig("codex", "display_name_present")
    assert_empty name_issue_codes(skill)
  end

  def test_reports_frontmatter_and_display_name_mismatches
    result = scan(
      "wayfinder" => {
        name: "Wayfinder",
        openai: <<~YAML
          interface:
            display_name: "Wayfinder"
        YAML
      }
    )

    assert_equal(
      %w[DISPLAY-NAME-MISMATCH NAME-MISMATCH],
      name_issue_codes(result.fetch("skills").first).sort
    )
  end

  def test_reports_missing_and_invalid_display_name_values
    result = scan(
      "missing-display" => {
        name: "missing-display",
        openai: <<~YAML
          interface:
            short_description: "No display name"
        YAML
      },
      "missing-interface" => {
        name: "missing-interface",
        openai: <<~YAML
          policy:
            allow_implicit_invocation: true
        YAML
      },
      "invalid-display" => {
        name: "invalid-display",
        openai: <<~YAML
          interface:
            display_name: 42
        YAML
      },
      "invalid-interface" => {
        name: "invalid-interface",
        openai: <<~YAML
          interface: "invalid"
        YAML
      }
    )

    issues_by_directory = result.fetch("skills").to_h do |skill|
      [skill.fetch("directory_name"), name_issue_codes(skill)]
    end

    assert_includes issues_by_directory.fetch("missing-display"), "DISPLAY-NAME-MISSING"
    assert_includes issues_by_directory.fetch("missing-interface"), "DISPLAY-NAME-MISSING"
    assert_includes issues_by_directory.fetch("invalid-display"), "DISPLAY-NAME-TYPE"
    assert_includes issues_by_directory.fetch("invalid-interface"), "OPENAI-INTERFACE-TYPE"
  end

  def test_reports_description_length_bands_and_hard_limit
    lengths = [49, 50, 300, 301, 500, 501]
    result = scan(
      lengths.to_h do |length|
        ["length-#{length}", { name: "length-#{length}", description: description_of_length(length) }]
      end
    )

    skills_by_directory = result.fetch("skills").to_h do |skill|
      [skill.fetch("directory_name"), skill]
    end

    expected_bands = {
      49 => "below_recommended",
      50 => "recommended",
      300 => "recommended",
      301 => "above_recommended",
      500 => "above_recommended",
      501 => "over_limit"
    }
    expected_bands.each do |length, band|
      skill = skills_by_directory.fetch("length-#{length}")
      assert_equal length, skill.fetch("description_length")
      assert_equal band, skill.fetch("description_length_band"), "length #{length}"
      assert_equal length > 500, issue_codes(skill).include?("DESCRIPTION-LENGTH"), "length #{length}"
    end
  end

  def test_counts_accented_characters_as_single_unicode_characters
    description = "Use when " + ("é" * 291)
    result = scan(
      "accented-description" => { name: "accented-description", description: description }
    )

    skill = result.fetch("skills").first
    assert_equal 300, skill.fetch("description_length")
    assert_equal "recommended", skill.fetch("description_length_band")
    refute_includes issue_codes(skill), "DESCRIPTION-LENGTH"
  end

  def test_flags_description_without_use_when_prefix
    result = scan(
      "no-prefix" => { name: "no-prefix", description: "Formats resumes for applicant tracking systems" },
      "with-prefix" => { name: "with-prefix", description: "Use when the user wants a resume formatted" }
    )

    codes = result.fetch("skills").to_h { |skill| [skill.fetch("directory_name"), issue_codes(skill)] }
    assert_includes codes.fetch("no-prefix"), "DESCRIPTION-PREFIX"
    refute_includes codes.fetch("with-prefix"), "DESCRIPTION-PREFIX"
  end

  def test_missing_openai_yaml_is_not_an_issue
    result = scan("claude-only" => { name: "claude-only", openai: nil })

    skill = result.fetch("skills").first
    assert_equal false, skill.dig("codex", "file_present")
    assert_empty issue_codes(skill)
  end

  private

  def scan(fixtures)
    Dir.mktmpdir("skills-lint-test") do |root|
      fixtures.each do |directory, fixture|
        write_skill(root, directory, **fixture)
      end

      stdout, stderr, status = Open3.capture3("ruby", SCANNER, root)
      assert status.success?, stderr
      return JSON.parse(stdout)
    end
  end

  def write_skill(
    root,
    directory,
    name:,
    description: "Use when testing skill name alignment",
    openai: "interface:\n  display_name: \"#{directory}\"\n"
  )
    skill_dir = File.join(root, directory)
    FileUtils.mkdir_p(skill_dir)
    File.write(
      File.join(skill_dir, "SKILL.md"),
      <<~MARKDOWN
        ---
        name: #{name}
        description: #{description.to_json}
        disable-model-invocation: false
        ---

        # Test skill
      MARKDOWN
    )

    return if openai.nil?

    agents_dir = File.join(skill_dir, "agents")
    FileUtils.mkdir_p(agents_dir)
    File.write(File.join(agents_dir, "openai.yaml"), openai)
  end

  def description_of_length(length)
    prefix = "Use when "
    prefix + ("x" * (length - prefix.length))
  end

  def issue_codes(skill)
    skill.fetch("static_issues").map { |finding| finding.fetch("code") }
  end

  def name_issue_codes(skill)
    issue_codes(skill).grep(/\A(?:NAME|DISPLAY-NAME|OPENAI-INTERFACE)/)
  end
end
