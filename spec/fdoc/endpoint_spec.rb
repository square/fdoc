require 'spec_helper'

describe Fdoc::Endpoint do
  let(:endpoint) { test_service.open(*fdoc_fixture) }
  let(:fdoc_fixture) { ["GET", "members/list"] }
  let (:test_service) { Fdoc::Service.new('spec/fixtures') }
  subject { endpoint }

  def remove_optional(obj)
    case obj
    when Hash
      res = {}
      obj.each do |k, v|
        next if k =~ /optional/
        res[k] = remove_optional(v)
      end
      obj.clear
      obj.merge!(res)
    when Array then obj.map { |v| remove_optional(v) }
    else obj
    end
  end

  describe "#verb" do
    it "infers the verb from the filename and service" do
      subject.verb.should == "GET"
    end
  end

  describe "#path" do
    it "infers its path from the filename and service" do
      subject.path.should == "members/list"
    end
  end

  describe "#consume_request" do
    subject { endpoint.consume_request(params) }
    let(:params) {
      {
        "limit" => 0,
        "offset" => 100,
        "order_by" => "name"
      }
    }

    context "with a well-behaved request" do
      it "returns true" do
        subject.should be_true
      end
    end

    context "when the response contains additional properties" do
      before { params.merge!("extra_goodness" => true) }

      it "should have the unknown keys in the error message" do
        expect { subject }.to raise_exception(JSON::Schema::ValidationError, /extra_goodness/)
      end
    end

    context "when the response contains an unknown enum value" do
      before { params.merge!("order_by" => "some_stuff") }

      it "should have the value in the error messages" do
        expect { subject }.to raise_exception(JSON::Schema::ValidationError, /some_stuff/)
      end
    end

    context "when the response encounters an object of an known type" do
      before { params.merge!("offset" => "woot") }

      it "should have the Ruby type in the error message" do
        expect { subject }.to raise_exception(JSON::Schema::ValidationError, /String/)
      end
    end

    context "complex examples" do
      let(:fdoc_fixture) { ["GET", "/members/list/complex-params"] }
      let(:params) {
        {
          "toplevel_param" => "here",
          "optional_nested_array" => [
            {
              "required_param" => "here",
              "optional_param" => "here"
            }
          ],
          "required_nested_array" => [
            {
              "required_param" => "here",
              "optional_param" => "here",
              "optional_second_nested_object" => {
                "required_param" => "here",
                "optional_param" => "here"
              }
            },
          ],
          "optional_nested_object" => {
            "required_param" => "here",
            "optional_param" => "here"
          },
          "required_nested_object" => {
            "required_param" => "here",
            "optional_param" => "here",
            "optional_second_nested_object" => {
              "required_param" => "here",
              "optional_param" => "here"
            }
          },
        }
      }

      it "is successful" do
        subject.should be_true
      end

      context "with no optional keys" do
        before { remove_optional(params) }

        it "does not contain optional keys" do
          params.keys.sort.should == ["required_nested_array", "required_nested_object", "toplevel_param"]
        end

        it "is successful" do
          subject.should be_true
        end
      end

      context "non documented field added" do
        before { params.merge!("non_documented" => true) }
        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "non document field in an optional array" do
        before { params["optional_nested_array"][0].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "non document field in a required array" do
        before { params["required_nested_array"][0].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "non document field in an optional object" do
        before { params["optional_nested_object"].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "non document field in a required object" do
        before { params["required_nested_object"].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "non document field in a deeply nested object" do
        before { params["required_nested_object"]["optional_second_nested_object"].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "required field in a deeply nested object is missing" do
        before { params["required_nested_object"]["optional_second_nested_object"].delete("required_param") }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /required_param/)
        end
      end

      context "non document field in a deeply nested object in an array" do
        before { params["required_nested_array"][0]["optional_second_nested_object"].merge!("non_documented" => true) }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /non_documented/)
        end
      end

      context "required field in a deeply nested object is missing" do
        before { params["required_nested_array"][0]["optional_second_nested_object"].delete("required_param") }

        it "raises an error" do
          expect { subject }.to raise_exception(JSON::Schema::ValidationError, /required_param/)
        end
      end
    end
  end

  describe "#consume_response" do
    good_response_params = {
      "members" => [
        {"name" => "Captain Smelly Pants"},
        {"name" => "Sally Pants"},
        {"name" => "Joe Shorts"}
      ]
    }

    it "throws an error when there is no response corresponding to the success-code error" do
      expect { subject.consume_response(good_response_params, "404 Not Found") }.to raise_exception Fdoc::UndocumentedResponseCode
      expect { subject.consume_response(good_response_params, "200 OK", false) }.to raise_exception Fdoc::UndocumentedResponseCode
    end

    context "for successful responses" do
      it "validates the response parameters against the schema" do
        subject.consume_response(good_response_params, "200 OK").should be_true
      end

      it "allows either fully-qualified or integer HTTP status codes" do
        subject.consume_response(good_response_params, 200).should be_true
      end

      context "with unknown keys" do
        it "throws an error when there an unknown key at the top level" do
          bad_params = good_response_params.merge({"extra_goodness" => true})
          expect { subject.consume_response(bad_params, "200 OK") }.to raise_exception JSON::Schema::ValidationError
        end

        it "throws an error when there is an unknown key a few layers deep" do
          bad_nested_params = good_response_params.dup
          bad_nested_params["members"][0]["smelliness"] = "the_max"
          expect { subject.consume_response(bad_nested_params, "200 OK") }.to raise_exception JSON::Schema::ValidationError
        end
      end
    end

    context "for unsuccessful responses" do
      context "when there is a valid success-code response" do
        it "does not throw an error with bad response parameters" do
          bad_params = good_response_params.merge({"extra_goodness" => true})
          subject.consume_response(bad_params, "400 Bad Request", false).should be_true
        end
      end
    end
  end
end
