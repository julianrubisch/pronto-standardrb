require "spec_helper"

module Pronto
  RSpec.describe Standardrb do
    let(:standardrb) { Standardrb.new(patches) }
    let(:patches) { nil }
    let(:pronto_config) do
      instance_double Pronto::ConfigFile, to_h: config_hash
    end
    let(:config_hash) { {} }

    before do
      allow(Pronto::ConfigFile).to receive(:new) { pronto_config }
    end

    describe "#run" do
      subject { standardrb.run }

      context "patches are nil" do
        it { should == [] }
      end

      context "no patches" do
        let(:patches) { [] }
        it { should == [] }
      end

      context "patches with smells" do
        include_context "test repo"

        let(:patches) { repo.diff("2dec0010") }

        its(:count) { should == 2 }

        it "includes the offense messages" do
          expect(subject.first.msg).to include("Style/StringLiterals")
          expect(subject.last.msg).to include("Layout/DefEndAlignment")
        end
      end
    end
  end
end
