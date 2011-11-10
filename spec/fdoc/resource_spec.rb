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
      subject.action('add').required_request_parameters.map(&:name).should == %w(name)
    end

    it "stores optional parameters for an action" do
      subject.action('add').optional_request_parameters.map(&:name).should == %w(email)
    end

    it "stores the successful responses" do
      subject.action('add').successful_response_codes.map(&:status).should == ["200 OK"]
    end

    it "stores the failure responses" do
      subject.action('add').failure_response_codes.map(&:status).should == ["400 Bad Request"]
    end

    context "without a controller" do
      before { resource_data.delete("Controller") }

      it "raises an error" do
        expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
      end
    end

    context "without a Resource Name" do
      before { resource_data.delete("Resource Name") }

      it "raises an error" do
        expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
      end
    end

    context "without a Methods" do
      before { resource_data.delete("Methods") }

      it "raises an error" do
        expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
      end
    end
  end
end

describe Fdoc::Method do
  subject { described_class.new(action_data)}
  let(:action_data) { YAML.load_file(fixture_file) }
  let(:fixture_file) { "#{FIXTURE_PATH}/method.fdoc" }

  it "contains the name" do
    subject.name.should == "add"
  end

  it "contains the verb" do
    subject.verb.should == "PUT"
  end

  it "contains the description" do
    subject.description.should == "Add a new member"
  end

  it "contains ordered request parameters" do
    subject.request_parameters.should have(2).items
    subject.request_parameters.map(&:name).should == %w(name email)
  end

  it "creates ResponseParameters" do
    subject.response_parameters.each { |param| param.should be_an_instance_of(Fdoc::ResponseParameter) }
  end

  it "creates RequestParameters" do
    subject.request_parameters.each { |param| param.should be_an_instance_of(Fdoc::RequestParameter) }
  end

  context "without request parameters" do
    before { action_data.delete "Request Parameters" }

    it "has no request params" do
      subject.request_parameters.should be_empty
    end
  end


  context "without response codes" do
    before { action_data.delete "Response Codes" }

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
    its(:required?) { should be_nil }
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

describe Fdoc::RequestParameter do
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


  context "without required" do
    let(:required) { nil }

    it "raises an error" do
      expect { subject }.to raise_exception(Fdoc::MissingAttributeError)
    end
  end
end

describe Fdoc::ResponseCode do
  subject { described_class.new(response_data) }
  let(:response_data) { YAML.load_file(fixture_file) }
  let(:fixture_file) { "#{FIXTURE_PATH}/response_code.fdoc" }

  its(:status) { should == "200 OK" }
  its(:successful?) { should == true }
  its(:description) { should == "A list of current members" }
end