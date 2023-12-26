require 'spec_helper'

describe Fdoc::EndpointScaffold do
  subject { described_class.new('spec/fixtures/network-GET.fdoc') }
  let(:action_parameters) { {
    "scaffold" => true,
    "description" => "???",
    "responseCodes" => []
  } }

  describe "#consume_request" do
    request_params = {
      "depth" => 5,
      "max_connections" => 20,
      "root_node" => "41EAF42"
    }

    before(:each) do
      subject.request_parameters.should be_empty
    end

    it "creates properties for top-level keys, and populates them with examples" do
      subject.consume_request(request_params, true)
      subject.request_parameters["type"].should == nil
      subject.request_parameters["properties"].should have(3).keys
      subject.request_parameters["properties"]["depth"]["type"].should == "integer"
      subject.request_parameters["properties"]["max_connections"]["example"].should == 20
      subject.request_parameters["properties"]["root_node"]["type"].should == "string"
    end

    it "infers boolean types" do
      bool_params = {
        "with_cheese" => false,
        "hold_the_lettuce" => true
      }
      subject.consume_request(bool_params)
      subject.request_parameters["properties"].should have(2).keys
      subject.request_parameters["properties"]["with_cheese"]["type"].should == "boolean"
      subject.request_parameters["properties"]["hold_the_lettuce"]["type"].should == "boolean"
    end

    context "infers formats" do
      it "detects date-time formats as objects, or as is08601 strings" do
        datetime_params = {
          "time_str" => Time.now.iso8601,
          "time_obj" => Time.now
        }
        subject.consume_request(datetime_params)
        subject.request_parameters["properties"].should have(2).keys
        subject.request_parameters["properties"]["time_str"]["type"].should == "string"
        subject.request_parameters["properties"]["time_str"]["format"].should == "date-time"
        subject.request_parameters["properties"]["time_obj"]["type"].should == "string"
        subject.request_parameters["properties"]["time_obj"]["format"].should == "date-time"
      end

      it "detects uri formats" do
        uri_params = {
          "sample_uri" => "http://my.example.com"
        }
        subject.consume_request(uri_params)
        subject.request_parameters["properties"].should have(1).keys
        subject.request_parameters["properties"]["sample_uri"]["type"].should == "string"
        subject.request_parameters["properties"]["sample_uri"]["format"].should == "uri"
      end

      it "detects color formats (hex only for now)" do
        color_params = { "page_color" => "#AABBCC" }
        subject.consume_request(color_params)
        subject.request_parameters["properties"]["page_color"]["type"].should == "string"
        subject.request_parameters["properties"]["page_color"]["format"].should == "color"
      end
    end

    it "uses strings (not symbols) as keys" do
      mixed_params = {
        :with_symbol => false,
        "with_string" => true
      }
      subject.consume_request(mixed_params)
      subject.request_parameters["properties"].should have(2).keys
      subject.request_parameters["properties"].should have_key "with_symbol"
      subject.request_parameters["properties"].should_not have_key :with_symbol
      subject.request_parameters["properties"].should have_key "with_string"
      subject.request_parameters["properties"].should_not have_key :with_string
    end

    it "uses strings (not symbols) for keys of nested hashes" do
      mixed_params = {
        "nested_object" => {
          :with_symbol => false,
          "with_string" => true
        }
      }

      subject.consume_request(mixed_params)
      subject.request_parameters["properties"]["nested_object"]["properties"].keys.sort.should == ["with_string", "with_symbol"]
    end

    it "uses strings (not symbols) for nested hashes inside arrays" do
      mixed_params = {
        "nested_array" => [
          {
            :with_symbol => false,
            "with_string" => true
          }
        ]
      }

      subject.consume_request(mixed_params)
      subject.request_parameters["properties"]["nested_array"]["items"]["properties"].keys.sort.should == ["with_string", "with_symbol"]
    end

    it "produces a valid JSON schema for the response" do
      subject.consume_request(request_params)
      subject.request_parameters["properties"].should have(3).keys
      JSON::Validator.validate!(subject.request_parameters, request_params).should be true
    end
  end

  describe "#consume_response" do
    let(:response_params) { {
      "nodes" => [{
          "id" => "12941",
          "name" => "Bobjoe Smith",
          "linked_to" => [ "111", "121", "999"]
        }, {
          "id" => "111",
          "name" => "Sally",
          "linked_to" => ["12941"]
        }, {
          "id" => "121",
          "name" => "Captain Smellypants",
          "linked_to" => ["12941", "999"]
        }, {
          "id" => "999",
          "name" => "Linky McLinkface",
          "linked_to" => ["12941", "121"]
        }
      ],
      "root_node" => {
        "id" => "12941",
        "name" => "Bobjoe Smith",
        "linked_to" => [ "111", "121", "999"]
      },
      "version" => 1,
      "std_dev" => 1.231,
      "updated_at" => nil
    } }



    context "for succesful responses" do
      before(:each) do
        subject.should have(0).response_codes
      end

      it "adds response codes" do
        subject.consume_response({}, "200 OK")
        subject.should have(1).response_codes

        subject.consume_response({}, "201 Created")
        subject.should have(2).response_codes
      end

     it "does not add duplicate response codes" do
        subject.consume_response({}, "200 OK")
        subject.should have(1).response_codes

        subject.consume_response({}, "200 OK")
        subject.should have(1).response_codes

        subject.response_codes.each do |response|
          response["description"].should == "???"
        end
      end

      it "creates properties for top-level keys, and populates them with examples" do
        subject.consume_response(response_params, "200 OK")
        subject.response_parameters["type"].should == nil
        subject.response_parameters["properties"].keys.should =~ ["nodes", "root_node", "std_dev", "version", "updated_at"]

        subject.response_parameters["properties"]["nodes"]["type"].should == "array"
        subject.response_parameters["properties"]["nodes"]["description"].should == "???"
        subject.response_parameters["properties"]["nodes"]["required"].should == "???"

        subject.response_parameters["properties"]["root_node"]["type"].should == "object"
        subject.response_parameters["properties"]["root_node"]["description"].should == "???"
        subject.response_parameters["properties"]["root_node"]["required"].should == "???"

        subject.response_parameters["properties"]["version"]["type"].should == "integer"
        subject.response_parameters["properties"]["std_dev"]["type"].should == "number"
      end

      it "populates items in arrays" do
        subject.consume_response(response_params, "200 OK")
        subject.response_parameters["properties"]["nodes"]["type"].should == "array"
        subject.response_parameters["properties"]["nodes"]["items"]["type"].should == "object"
        subject.response_parameters["properties"]["nodes"]["items"]["properties"].keys.sort.should == [
          "id", "linked_to","name"]
      end

      it "turns nil into null" do
        subject.consume_response(response_params, "200 OK")
        subject.response_parameters["properties"]["updated_at"]["type"].should == "null"
      end

      it "uses strings (not symbols) as keys" do
        mixed_params = {
          :with_symbol => false,
          "with_string" => true
        }
        subject.consume_response(mixed_params, "200 OK")
        subject.response_parameters["properties"].should have(2).keys
        subject.response_parameters["properties"].should have_key "with_symbol"
        subject.response_parameters["properties"].should_not have_key :with_symbol
        subject.response_parameters["properties"].should have_key "with_string"
        subject.response_parameters["properties"].should_not have_key :with_string
      end

      it "produces a valid JSON schema for the response" do
        subject.consume_response(response_params, "200 OK")
        JSON::Validator.validate!(subject.response_parameters, response_params).should be true
      end
    end

    context "for unsuccessful responses" do
      it "adds response codes" do
        subject.should have(0).response_codes
        subject.consume_response({}, "400 Bad Request", false)
        subject.should have(1).response_codes
        subject.consume_response({}, "404 Not Found", false)
        subject.should have(2).response_codes
      end

      it "does not modify the response_parameters" do
        subject.response_parameters.should be_empty
        subject.consume_response(response_params, "403 Forbidden", false)
        subject.response_parameters.should be_empty
      end
    end
  end
end
