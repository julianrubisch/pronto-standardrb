require "pronto/standardrb/version"
require "pronto"
require "standard"

module Pronto
  class Standardrb < Runner
    def initialize
      @builds_config = Standard::BuildsConfig.new
    end
    
    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
              .map { |patch| inspect(patch) }
              .flatten.compact
    end

    # copied from rubocop-runner, since standardrb is essentially a wrapper
    def valid_patch?(patch)
      return false if patch.additions < 1

      path = patch.new_file_full_path

      ruby_file?(path)
    end

    def inspect(patch)
    end
  end
end
