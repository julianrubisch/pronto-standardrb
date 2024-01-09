require "pronto/standardrb/version"
require "pronto"
require "rubocop"
require "standard"

module Pronto
  class Standardrb < Runner
    def run
      ruby_patches.flat_map do |patch|
        next [] unless valid?(patch)

        offenses(patch).flat_map do |offense|
          patch
            .added_lines
            .select { |line| line.new_lineno == offense.line }
            .map { |line| new_message(offense, line) }
        end
      end
    end

    def rubocop_config(patch)
      builds_config = Standard::BuildsConfig.new
      config = builds_config.call([])

      @rubocop_config ||= begin
        store = config.rubocop_config_store
        store.for(path(patch))
      end
    end

    private

    def valid?(patch)
      return false if rubocop_config(patch).file_to_exclude?(path(patch))

      rubocop_config(patch).file_to_include?(path(patch))
    end

    def processed_source(patch)
      processed_source = ::RuboCop::ProcessedSource.from_file(
        path(patch),
        rubocop_config(patch).target_ruby_version
      )
      processed_source.registry = registry if processed_source.respond_to?(:registry=)
      processed_source.config = rubocop_config(patch) if processed_source.respond_to?(:config=)
      processed_source
    end

    def new_message(offense, line)
      path = line.patch.delta.new_file[:path]
      level = level(offense.severity.name)
      Message.new(path, line, level, offense.message, nil, self.class)
    end

    def offenses(patch)
      team(patch)
        .inspect_file(processed_source(patch))
        .sort
        .reject(&:disabled?)
    end

    def path(patch)
      patch.new_file_full_path.to_s
    end

    def team(patch)
      @team ||= ::RuboCop::Cop::Team.new(registry, rubocop_config(patch))
    end

    def registry
      @registry ||= ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
    end

    def level(severity)
      severities.fetch(severity)
    end

    def severities
      DEFAULT_SEVERITIES
    end

    DEFAULT_SEVERITIES = {
      refactor: :warning,
      convention: :warning,
      warning: :warning,
      error: :error,
      fatal: :fatal
    }.freeze
  end
end
