require "pronto/standardrb/version"
require "pronto"
require "pronto/rubocop"
require "pry"
require "standard"

module Pronto
  class Standardrb < Rubocop
    def initialize(patches, _ = nil)
      super(patches)

      @builds_config = Standard::BuildsConfig.new

      config = @builds_config.call([])
      @inspector = ::RuboCop::Runner.new(config.rubocop_options, @config_store)
    end
  end
end
