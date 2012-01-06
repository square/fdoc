require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Fdoc::Resource do
  subject { described_class.new(resource_data) }
  let(:resource_data) { YAML.load_file(File.join(FIXTURES_PATH, "members.fdoc")) }

  describe "#action_for" do
    context "with no options" do
      context "when an action exists" do
        it "should return an Action object wrapping the specified action" do
          subject.action_for("GET", "list").should be_kind_of Fdoc::Action
        end

        it "should not return a scaffold" do
          subject.action_for("GET", "list").scaffold?.should be_false
        end
      end

      context "when a scaffold exists" do
        it "should return nil" do
          subject.action_for("POST", "draft").should be_nil
        end
      end

      context "when an action does not exist" do
        it "should return nil" do
          subject.action_for("POST", "nonexistent").should be_nil
        end
      end
    end

    context "with the scaffolding option" do
      options = {:scaffold => true}

      context "when an action exists" do
        it "raises an error" do
          expect { subject.action_for("GET", "list", options) }.to raise_exception Fdoc::ActionAlreadyExistsError
        end
      end

      context "when an action does not exist" do
        it "creates a scaffold for that method" do
          action = subject.action_for("POST", "nonexistent", options)
          action.should be_kind_of Fdoc::Action
          action.scaffold?.should be_true
        end
      end
    end
  end
end
