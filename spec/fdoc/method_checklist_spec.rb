path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc::MethodChecklist do
  let(:mthod)        { Fdoc::Method.new(method_data) }
  let(:method_data)  { YAML.load_file(fixture_file) }
  let(:fixture_file) { "#{FIXTURE_PATH}/method.fdoc.part" }

  describe "#consume_request" do
    subject { described_class.new(mthod).consume_request(request_parameters) }
    let(:valid_request_parameters) { {"name" => "Captain Smellypants",
                                      "email" => "smelly@pants.com",
                                      "address" => "Stinkville"} }

    context "valid request parameters" do
      let(:request_parameters) { valid_request_parameters }

      it { should == true }
    end

    context "when required parameters are missing" do
      let(:request_parameters) do
        valid_request_parameters.tap { |params|
          params.delete('name')
          params.delete('address')
        }
      end

      it "raises a MissingRequiredParameterError listing all of the missing parameters" do
        expect { subject }.to raise_exception Fdoc::MissingRequiredParameterError,
                                              /address.*name/
      end
    end

    context "an undocumented parameter is present" do
      let(:request_parameters) { valid_request_parameters.merge({"age" => 100, "gender" => :male}) }

      it "raises an UndocumentedParameterError" do
        expect { subject }.to raise_exception Fdoc::UndocumentedParameterError,
                                              /age.*gender/

      end
    end
  end

  describe "#consume_response" do
    subject { described_class.new(mthod).consume_response(response_parameters, response_code, success)}
    let(:valid_response_parameters) { {"success" => true, "member_id" => "4a45eaf"} }
    let(:valid_response_code)       { "201 Created" }
    let(:success)                   { true          }

    context "valid response parameters" do
      let(:response_parameters) { valid_response_parameters }
      let(:response_code) { valid_response_code }

      it "returns true" do
        subject.should == true
      end
    end

    context "an undocumented response parameter is present" do
      let(:response_parameters) { valid_response_parameters.merge({"date_created" => "2011-11-1"}) }
      let(:response_code) { valid_response_code }

      it "raises an UndocumentedParameterError" do
        expect { subject }.to raise_exception(Fdoc::UndocumentedParameterError)
      end
    end

    context "valid response parameters" do
      let(:response_parameters) { valid_response_parameters }
      let(:response_code) { valid_response_code }

      it "returns true" do
        subject.should == true
      end
    end

    context "an undocumented response parameter is present" do
      let(:response_parameters) { valid_response_parameters }
      let(:response_code) { "500 Internal Server Error" }

      it "raises an UndocumentedParameterError" do
        expect { subject }.to raise_exception(Fdoc::UndocumentedResponseCodeError)
      end
    end

    context "the api response was not successful" do
      let(:success) { false }

      context "without response parameter keys" do
        let(:response_parameters) { {} }
        let(:response_code) { "400 Bad Request" }

        it "returns true" do
          subject.should == true
        end
      end

      context "status is undocumented" do
        let(:response_parameters) { valid_response_parameters }
        let(:response_code) { "500 Internal Server Error" }

        it "raises an UndocumentedResponseCodeError" do
          expect { subject }.to raise_exception(Fdoc::UndocumentedResponseCodeError)
        end
      end

      context "status is documented only as successful" do
        let(:response_parameters) { valid_response_parameters }
        let(:response_code) { "201 Created" }

        it "raises an UndocumentedResponseCodeError" do
          expect { subject }.to raise_exception(Fdoc::UndocumentedResponseCodeError)
        end
      end
    end
  end
end