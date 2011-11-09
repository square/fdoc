path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc::Resource do
  subject { described_class.new(resource_data) }
  let(:resource_data) { YAML.load_file(fixture_file) }

  describe "Loading a resource" do
    let(:fixture_file) { "#{FIXTURE_PATH}/members.fdoc" }
    
    it "parses out the resource name" do
      subject.name.should == "members"
    end
    
    it "parses out the actions in order defined" do
      subject.actions.map(&:name).should == %w(list add)
    end
    
    it "stores required parameters for an action" do
      subject.action(:add).required_parameters.map(&:name).should == %w(name)
    end
    
    it "stores optional parameters for an action" do
      subject.action(:add).optional_parameters.map(&:name).should == %w(email)
    end
    
    it "stores the successfull responses" do
      subject.action(:add).success_responses.map(&:status).should == ["200 OK"]
    end
    
    it "stores the failure responses" do
      subject.action(:add).failure_responses.map(&:status).should == ["400 Bad Request"]
    end
  end 
end

describe Fdoc::Action do
  subject { described_class.new(action_data)}
  let(:action_data) { YAML.load_file(fixture_file) }
  let(:fixture_file) { "#{FIXTURE_PATH}/action.fdoc" }
  
  it "contains the name" do
    subject.name.should == "list"
  end
  
  it "contains the verb" do
    subject.verb.should == "GET"
  end
  
  it "contains the description" do
    subject.description.should == "The list of members."
  end
  
  it "contains ordered parameters" do
    subject.parameters.should have(2).items
    subject.parameters.map(&:name).should == %w(limit offset)
  end
  
  context "without responses" do
    before { action_data.delete "Responses" }
    
    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end
  
  context "without a verb" do
    before { action_data.delete "Verb" }
    
    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end
end

describe Fdoc::Parameter do
  subject { described_class.new(parameter_data) }
  let(:parameter_data) { YAML.load(parameter_yaml) }
  let(:parameter_yaml) { <<-EOS
#{"Name: #{name}" if name}
#{"Type: #{type}" if type}
#{"Required: #{required}" if required}
#{"Description: #{description}" if description}
#{"Example: #{example}" if example}
#{"Default: #{default}" if default}
#{"Values: #{values}" if values}
EOS
  }
    
  let(:name) { "name" }
  let(:type) { "String" }
  let(:required) { true }
  let(:description) { "A brief description" }
  let(:example) { "string" }
  let(:default) { "McLovin"}
  let(:values) { "An alphanumeric string"}

  its(:name) { should == name }
  its(:type) { should == type }
  its(:required?) { should == required }
  its(:description) { should == description }
  its(:example) { should == example }
  its(:default) { should == default }
  its(:values) { should == values }

  context "without name" do
    let(:name) { nil }
    
    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end

  context "without type" do
    let(:type) { nil }
    
    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end

  context "without required" do
    let(:required) { nil }
    
    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end
  
  context "without description" do
    let(:description) { nil }
    its(:description) { should be_nil }
  end    

  context "without example" do
    let(:example) { nil }
    its(:example) { should be_nil }
  end    

  context "without default" do
    let(:default) { nil }
    its(:default) { should be_nil }
  end    
  
  context "without values" do
    let(:values) { nil }
    its(:values) { should be_nil }
  end
end
