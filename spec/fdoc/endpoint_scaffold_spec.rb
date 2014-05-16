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
      expect(subject.request_parameters).to be_empty
    end

    it "creates properties for top-level keys, and populates them with examples" do
      subject.consume_request(request_params, true)
      expect(subject.request_parameters["type"]).to eq(nil)
      expect(subject.request_parameters["properties"].keys.size).to eq(3)
      expect(subject.request_parameters["properties"]["depth"]["type"]).to eq("integer")
      expect(subject.request_parameters["properties"]["max_connections"]["example"]).to eq(20)
      expect(subject.request_parameters["properties"]["root_node"]["type"]).to eq("string")
    end

    it "infers boolean types" do
      bool_params = {
        "with_cheese" => false,
        "hold_the_lettuce" => true
      }
      subject.consume_request(bool_params)
      expect(subject.request_parameters["properties"].keys.size).to eq(2)
      expect(subject.request_parameters["properties"]["with_cheese"]["type"]).to eq("boolean")
      expect(subject.request_parameters["properties"]["hold_the_lettuce"]["type"]).to eq("boolean")
    end

    context "infers formats" do
      it "detects date-time formats as objects, or as is08601 strings" do
        datetime_params = {
          "time_str" => Time.now.iso8601,
          "time_obj" => Time.now
        }
        subject.consume_request(datetime_params)
        expect(subject.request_parameters["properties"].keys.size).to eq(2)
        expect(subject.request_parameters["properties"]["time_str"]["type"]).to eq("string")
        expect(subject.request_parameters["properties"]["time_str"]["format"]).to eq("date-time")
        expect(subject.request_parameters["properties"]["time_obj"]["type"]).to eq("string")
        expect(subject.request_parameters["properties"]["time_obj"]["format"]).to eq("date-time")
      end

      it "detects uri formats" do
        uri_params = {
          "sample_uri" => "http://my.example.com"
        }
        subject.consume_request(uri_params)
        expect(subject.request_parameters["properties"].keys.size).to eq(1)
        expect(subject.request_parameters["properties"]["sample_uri"]["type"]).to eq("string")
        expect(subject.request_parameters["properties"]["sample_uri"]["format"]).to eq("uri")
      end

      it "detects color formats (hex only for now)" do
        color_params = { "page_color" => "#AABBCC" }
        subject.consume_request(color_params)
        expect(subject.request_parameters["properties"]["page_color"]["type"]).to eq("string")
        expect(subject.request_parameters["properties"]["page_color"]["format"]).to eq("color")
      end
    end

    it "uses strings (not symbols) as keys" do
      mixed_params = {
        :with_symbol => false,
        "with_string" => true
      }
      subject.consume_request(mixed_params)
      expect(subject.request_parameters["properties"].keys.size).to eq(2)
      expect(subject.request_parameters["properties"]).to have_key "with_symbol"
      expect(subject.request_parameters["properties"]).not_to have_key :with_symbol
      expect(subject.request_parameters["properties"]).to have_key "with_string"
      expect(subject.request_parameters["properties"]).not_to have_key :with_string
    end

    it "uses strings (not symbols) for keys of nested hashes" do
      mixed_params = {
        "nested_object" => {
          :with_symbol => false,
          "with_string" => true
        }
      }

      subject.consume_request(mixed_params)
      expect(subject.request_parameters["properties"]["nested_object"]["properties"].keys.sort).to eq(["with_string", "with_symbol"])
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
      expect(subject.request_parameters["properties"]["nested_array"]["items"]["properties"].keys.sort).to eq(["with_string", "with_symbol"])
    end

    it "produces a valid JSON schema for the response" do
      subject.consume_request(request_params)
      expect(subject.request_parameters["properties"].keys.size).to eq(3)
      expect(JSON::Validator.validate!(subject.request_parameters, request_params)).to be_true
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
        expect(subject.response_codes.size).to eq(0)
      end

      it "adds response codes" do
        subject.consume_response({}, "200 OK")
        expect(subject.response_codes.size).to eq(1)

        subject.consume_response({}, "201 Created")
        expect(subject.response_codes.size).to eq(2)
      end

     it "does not add duplicate response codes" do
        subject.consume_response({}, "200 OK")
        expect(subject.response_codes.size).to eq(1)

        subject.consume_response({}, "200 OK")
        expect(subject.response_codes.size).to eq(1)

        subject.response_codes.each do |response|
          expect(response["description"]).to eq("???")
        end
      end

      it "creates properties for top-level keys, and populates them with examples" do
        subject.consume_response(response_params, "200 OK")
        expect(subject.response_parameters["type"]).to eq(nil)
        expect(subject.response_parameters["properties"].keys).to match_array(["nodes", "root_node", "std_dev", "version", "updated_at"])

        expect(subject.response_parameters["properties"]["nodes"]["type"]).to eq("array")
        expect(subject.response_parameters["properties"]["nodes"]["description"]).to eq("???")
        expect(subject.response_parameters["properties"]["nodes"]["required"]).to eq("???")

        expect(subject.response_parameters["properties"]["root_node"]["type"]).to eq("object")
        expect(subject.response_parameters["properties"]["root_node"]["description"]).to eq("???")
        expect(subject.response_parameters["properties"]["root_node"]["required"]).to eq("???")

        expect(subject.response_parameters["properties"]["version"]["type"]).to eq("integer")
        expect(subject.response_parameters["properties"]["std_dev"]["type"]).to eq("number")
      end

      it "populates items in arrays" do
        subject.consume_response(response_params, "200 OK")
        expect(subject.response_parameters["properties"]["nodes"]["type"]).to eq("array")
        expect(subject.response_parameters["properties"]["nodes"]["items"]["type"]).to eq("object")
        expect(subject.response_parameters["properties"]["nodes"]["items"]["properties"].keys.sort).to eq([
          "id", "linked_to","name"])
      end

      it "turns nil into null" do
        subject.consume_response(response_params, "200 OK")
        expect(subject.response_parameters["properties"]["updated_at"]["type"]).to eq("null")
      end

      it "uses strings (not symbols) as keys" do
        mixed_params = {
          :with_symbol => false,
          "with_string" => true
        }
        subject.consume_response(mixed_params, "200 OK")
        expect(subject.response_parameters["properties"].keys.size).to eq(2)
        expect(subject.response_parameters["properties"]).to have_key "with_symbol"
        expect(subject.response_parameters["properties"]).not_to have_key :with_symbol
        expect(subject.response_parameters["properties"]).to have_key "with_string"
        expect(subject.response_parameters["properties"]).not_to have_key :with_string
      end

      it "produces a valid JSON schema for the response" do
        subject.consume_response(response_params, "200 OK")
        expect(JSON::Validator.validate!(subject.response_parameters, response_params)).to be_true
      end
    end

    context "for unsuccessful responses" do
      it "adds response codes" do
        expect(subject.response_codes.size).to eq(0)
        subject.consume_response({}, "400 Bad Request", false)
        expect(subject.response_codes.size).to eq(1)
        subject.consume_response({}, "404 Not Found", false)
        expect(subject.response_codes.size).to eq(2)
      end

      it "does not modify the response_parameters" do
        expect(subject.response_parameters).to be_empty
        subject.consume_response(response_params, "403 Forbidden", false)
        expect(subject.response_parameters).to be_empty
      end
    end
  end
end
