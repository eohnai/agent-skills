#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"
require "yaml"

# Default target: the agent-skills repo this script lives in
# (<repo>/<category>/skills-lint/scripts/scan_skills.rb).
DEFAULT_ROOT = File.expand_path("../../..", __dir__)
DESCRIPTION_PREFIX = "Use when "
DESCRIPTION_MAX_LENGTH = 500
DESCRIPTION_RECOMMENDED_LENGTH = (50..300).freeze

def issue(skill_id, code, severity, message)
  {
    "id" => "#{skill_id}-#{code}",
    "code" => code,
    "severity" => severity,
    "message" => message
  }
end

def load_yaml(text)
  value = YAML.safe_load(
    text,
    permitted_classes: [],
    permitted_symbols: [],
    aliases: false
  )
  value.nil? ? {} : value
end

def extract_frontmatter(content)
  match = content.match(/\A---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|\z)/m)
  return [nil, content, "missing YAML frontmatter"] unless match

  frontmatter = load_yaml(match[1])
  return [nil, content, "YAML frontmatter must be a mapping"] unless frontmatter.is_a?(Hash)

  body = content[match.end(0)..] || ""
  [frontmatter, body, nil]
rescue Psych::Exception => e
  [nil, content, e.message]
end

def nested_value(hash, *keys)
  keys.reduce(hash) do |value, key|
    break nil unless value.is_a?(Hash)

    value[key]
  end
end

def present_key?(hash, key)
  hash.is_a?(Hash) && hash.key?(key)
end

def description_length_band(length)
  return nil if length.nil?
  return "over_limit" if length > DESCRIPTION_MAX_LENGTH
  return "below_recommended" if length < DESCRIPTION_RECOMMENDED_LENGTH.min
  return "above_recommended" if length > DESCRIPTION_RECOMMENDED_LENGTH.max

  "recommended"
end

root = File.expand_path(ARGV[0] || DEFAULT_ROOT)
unless File.directory?(root)
  warn "Target directory does not exist: #{root}"
  exit 2
end

scan_errors = []
paths_by_realpath = {}

Dir.glob(File.join(root, "**", "SKILL.md"), File::FNM_DOTMATCH).sort.each do |path|
  begin
    paths_by_realpath[File.realpath(path)] ||= path
  rescue SystemCallError => e
    scan_errors << { "path" => path, "error" => e.message }
  end
end

skills = paths_by_realpath.values.sort.map do |skill_file|
  skill_dir = File.dirname(skill_file)
  relative_dir = Pathname.new(skill_dir).relative_path_from(Pathname.new(root)).to_s
  relative_dir = "." if relative_dir.empty?
  stable_source = File.realpath(skill_dir)
  skill_id = "S-#{Digest::SHA256.hexdigest(stable_source)[0, 8].upcase}"
  static_issues = []

  content = File.read(skill_file, encoding: "UTF-8")
  frontmatter, body, frontmatter_error = extract_frontmatter(content)

  if frontmatter_error
    static_issues << issue(skill_id, "SKILL-YAML", "error", frontmatter_error)
    frontmatter = {}
  end

  name = frontmatter["name"]
  description = frontmatter["description"]
  directory_name = File.basename(skill_dir)

  if name.nil? || (name.respond_to?(:empty?) && name.empty?)
    static_issues << issue(skill_id, "NAME-MISSING", "error", "frontmatter name is missing")
  elsif !name.is_a?(String)
    static_issues << issue(skill_id, "NAME-TYPE", "error", "frontmatter name must be a string")
  elsif name != directory_name
    static_issues << issue(
      skill_id,
      "NAME-MISMATCH",
      "warning",
      "frontmatter name #{name.inspect} differs from directory #{directory_name.inspect}"
    )
  end

  if description.nil?
    static_issues << issue(skill_id, "DESCRIPTION-MISSING", "error", "description is missing")
  elsif !description.is_a?(String)
    static_issues << issue(skill_id, "DESCRIPTION-TYPE", "error", "description must be a string")
  else
    unless description.start_with?(DESCRIPTION_PREFIX)
      static_issues << issue(
        skill_id,
        "DESCRIPTION-PREFIX",
        "warning",
        "description must start with #{DESCRIPTION_PREFIX.inspect}"
      )
    end
    if description.length > DESCRIPTION_MAX_LENGTH
      static_issues << issue(
        skill_id,
        "DESCRIPTION-LENGTH",
        "warning",
        "description has #{description.length} Unicode characters; maximum is #{DESCRIPTION_MAX_LENGTH}"
      )
    end
  end

  claude_present = present_key?(frontmatter, "disable-model-invocation")
  claude_value = frontmatter["disable-model-invocation"]
  if claude_present && claude_value != true && claude_value != false
    static_issues << issue(
      skill_id,
      "CLAUDE-POLICY-TYPE",
      "error",
      "disable-model-invocation must be a boolean"
    )
  end

  openai_file = File.join(skill_dir, "agents", "openai.yaml")
  openai_exists = File.file?(openai_file)
  openai_data = {}
  openai_error = nil

  # agents/openai.yaml is optional Codex metadata; a skill without it is fine.
  if openai_exists
    begin
      openai_data = load_yaml(File.read(openai_file, encoding: "UTF-8"))
      unless openai_data.is_a?(Hash)
        openai_error = "agents/openai.yaml must be a mapping"
        openai_data = {}
      end
    rescue Psych::Exception => e
      openai_error = e.message
    end
  end

  if openai_error
    static_issues << issue(skill_id, "OPENAI-YAML", "error", openai_error)
  end

  display_name_present = false
  display_name = nil
  if openai_exists && openai_error.nil?
    interface = openai_data["interface"]
    if interface.nil?
      static_issues << issue(
        skill_id,
        "DISPLAY-NAME-MISSING",
        "error",
        "interface.display_name is missing; expected #{directory_name.inspect}"
      )
    elsif !interface.is_a?(Hash)
      static_issues << issue(
        skill_id,
        "OPENAI-INTERFACE-TYPE",
        "error",
        "interface must be a mapping"
      )
    else
      display_name_present = interface.key?("display_name")
      display_name = interface["display_name"]
      if display_name.nil? || (display_name.respond_to?(:empty?) && display_name.empty?)
        static_issues << issue(
          skill_id,
          "DISPLAY-NAME-MISSING",
          "error",
          "interface.display_name is missing; expected #{directory_name.inspect}"
        )
      elsif !display_name.is_a?(String)
        static_issues << issue(
          skill_id,
          "DISPLAY-NAME-TYPE",
          "error",
          "interface.display_name must be a string"
        )
      elsif display_name != directory_name
        static_issues << issue(
          skill_id,
          "DISPLAY-NAME-MISMATCH",
          "warning",
          "interface.display_name #{display_name.inspect} differs from directory #{directory_name.inspect}"
        )
      end
    end
  end

  policy = openai_data["policy"]
  codex_present = policy.is_a?(Hash) && policy.key?("allow_implicit_invocation")
  codex_value = nested_value(openai_data, "policy", "allow_implicit_invocation")
  if codex_present && codex_value != true && codex_value != false
    static_issues << issue(
      skill_id,
      "CODEX-POLICY-TYPE",
      "error",
      "policy.allow_implicit_invocation must be a boolean"
    )
  end

  if [claude_value, codex_value].all? { |value| value == true || value == false }
    if claude_value == codex_value
      static_issues << issue(
        skill_id,
        "POLICY-CONFLICT",
        "warning",
        "Claude and Codex implicit invocation policies disagree"
      )
    end
  end

  headings = body.lines.each_with_object([]) do |line, values|
    match = line.match(/\A[#]{1,3}\s+(.+?)\s*\z/)
    values << match[1] if match
  end.first(24)

  description_length = description.is_a?(String) ? description.length : nil

  {
    "skill_id" => skill_id,
    "relative_path" => relative_dir,
    "skill_file" => skill_file,
    "directory_name" => directory_name,
    "name" => name,
    "description" => description,
    "description_length" => description_length,
    "description_length_band" => description_length_band(description_length),
    "claude" => {
      "field_present" => claude_present,
      "disable_model_invocation" => claude_value,
      "effective_disable_model_invocation" => claude_value == true
    },
    "codex" => {
      "file" => openai_file,
      "file_present" => openai_exists,
      "display_name_present" => display_name_present,
      "display_name" => display_name,
      "field_present" => codex_present,
      "allow_implicit_invocation" => codex_value,
      "effective_allow_implicit_invocation" => codex_value != false
    },
    "body_headings" => headings,
    "body_preview" => body.gsub(/\s+/, " ").strip[0, 800],
    "static_issues" => static_issues
  }
rescue EncodingError, SystemCallError => e
  scan_errors << { "path" => skill_file, "error" => e.message }
  nil
end.compact

result = {
  "schema_version" => 1,
  "root" => root,
  "counts" => {
    "skills" => skills.length,
    "skills_with_static_issues" => skills.count { |skill| !skill["static_issues"].empty? },
    "scan_errors" => scan_errors.length
  },
  "scan_errors" => scan_errors,
  "skills" => skills
}

puts JSON.pretty_generate(result)
