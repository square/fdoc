path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc do
  before(:each) do
    Fdoc.load(FIXTURES_PATH)
  end
  
  after(:each) do
    Fdoc.clear
  end

  describe "#resource_for" do
    context "when a there is a resource for that controller" do
      it "should return a Resource object wrapping that file" do
        Fdoc.resource_for("Api::MembersController").should be_kind_of Fdoc::Resource
      end
    end
    
    context "when there is not a resource for that controller" do
      it "should return nil" do
        Fdoc.resource_for("Api::UnknownController").should be_nil
      end
    end
  end
  
  describe "#scaffold_for" do
    it "should create resource object for that controller and add it to the module" do
      Fdoc.resource_for("Api::")
    end
    
    it "should attempt to guess the resource name based on the controller name" do
      Fdoc.scaffold_for("Api::PaymentsController").name.should == "payments"
    end
    
    it "should raise an exception when the real resource already exists" do
    end
  end
end