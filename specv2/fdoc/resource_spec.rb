path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc::Resource do
  subject { described_class.new(resource_data) }
  let(:resource_data) { YAML.load_file(File.join(FIXTURES_PATH, "members.fdoc")) }
  
  describe "#action_for" do
    context "with no options" do
      context "when an action exists" do
        it "should return an Action object wrapping the specified action" do
          subject.action_for("GET", "list").should be_kind_of Fdoc::Action
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
        it "creates a scaffold for that method"do
          subject.action_for("POST", "nonexistent", options).should be_kind_of Fdoc::Action
        end
      end
    end
  end
end