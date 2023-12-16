require "bundler/setup"
require "pry"
require "rspec"
require "rspec/its"
require "pronto/standardrb"
require "fileutils"

RSpec.shared_context "test repo" do
  let(:git) { "spec/fixtures/test.git/git" }
  let(:dot_git) { "spec/fixtures/test.git/.git" }

  before { FileUtils.mv(git, dot_git) }
  let(:repo) { Pronto::Git::Repository.new("spec/fixtures/test.git") }
  after { FileUtils.mv(dot_git, git) }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
