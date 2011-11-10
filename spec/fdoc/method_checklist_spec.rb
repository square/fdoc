path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc::MethodChecklist do
  let(:mthod)        { Fdoc::Method.new(method_data) }
  let(:method_data)  { YAML.load_file(fixture_file) }
  let(:fixture_file) { "#{FIXTURE_PATH}/method.fdoc" }

  describe "#consume_request_parameters" do
    subject { described_class.new(mthod).consume_request_parameters(request_parameters) }
    let(:valid_request_parameters) { {"name" => "Captain Smellypants", "email" => "smelly@pants.com"} }

    context "valid request parameters" do
      let(:request_parameters) { valid_request_parameters }

      it "returns true" do
        subject.should be_true
      end
    end

    context "a required request parameter is missing" do
      let(:request_parameters) { valid_request_parameters.delete("name"); valid_request_parameters }

      it "raises a MissingRequiredParameterError" do
        expect { subject }.to raise_exception(Fdoc::MissingRequiredParameterError)
      end
    end

    context "an undocumented parameter is present" do
      let(:request_parameters) { valid_request_parameters.merge({"age" => 100}) }

      it "raises an UndocumentedParameterError" do
        expect { subject }.to raise_exception(Fdoc::UndocumentedParameterError)
      end
    end
  end
end