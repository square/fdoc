require 'spec_helper'

describe Fdoc::Endpoint do
  subject {
    described_class.new("spec/fixtures/members/list/GET.fdoc", test_service)
  }
  
  let (:test_service) { Fdoc::Service.new('spec/fixtures') }

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
    good_params = {
      "limit" => 0,
      "offset" => 100,
      "order_by" => "name"
    }

    context "with a well-behaved request" do
      it "returns true" do
        subject.consume_request(good_params).should be_true
      end
    end

    context "with an extra key added in" do
      it "throws an exception" do
        expect { subject.consume_request(good_params.merge({"extra_goodness" => true})) }.to raise_exception
      end
    end

    context "error messages" do
      context "verifying json-schema gem verbosity" do
        context "when the response contains additional properties" do
          it "should have the unknown keys in the error message" do
            begin
              subject.consume_request(good_params.merge({"extra_goodness" => true}))
            rescue JSON::Schema::ValidationError => error
              error.message.should match("extra_goodness")
            end
          end
        end

        context "when the response contains an unknown enum value" do
          it "should have the value in the error messages" do
            begin
              subject.consume_request(good_params.merge({"order_by" => "some_stuff"}))
            rescue JSON::Schema::ValidationError => error
              error.message.should match("some_stuff")
            end
          end
        end

        context "when the response encounters an object of an known type" do
          it "should have the Ruby type in the error message" do
            begin
              subject.consume_request(good_params.merge({"order_by" => 1}))
            rescue JSON::Schema::ValidationError => error
              error.message.should match("Fixnum")
            end
          end
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
