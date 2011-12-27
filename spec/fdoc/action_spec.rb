path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc::Action do
  describe "consuming (validating)" do

    subject { described_class.new(list_action_data) }
    let(:list_action_data) { resource_data["actions"][0] }
    let(:resource_data) { YAML.load_file(File.join(FIXTURES_PATH, "members.fdoc")) }

    describe "#consume_request" do
      good_params = {
        "limit" => 0,
        "offset" => 100
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
  
  describe "scaffolding" do
    subject { described_class.new(action_parameters) }
    let(:action_parameters) { {
      "name" => "network",
      "verb" => "GET",
      "scaffold" => true,
      "description" => "???"
    } }  
    let(:resource) { Fdoc::Resource.build_from_file(resource_path) }
    let(:resource_path) { File.join(FIXTURES_PATH, "members.fdoc") }
    
    
    describe "#scaffold_request" do
      request_params = {
        "depth" => 5,
        "max_connections" => 20,
        "root_node" => "41EAF42"
      }

      before(:each) do
        subject.request_parameters.should be_empty
      end
      
      after(:each) do
        subject.instance_variable_set(:"@action", {})
      end
      
      context "when the action is a scaffold" do
        it "creates properties for top-level keys, and populates them with examples" do
          subject.scaffold_request(request_params)
          subject.request_parameters["type"].should == "object"
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
          subject.scaffold_request(bool_params)
          subject.request_parameters["properties"].should have(2).keys
          subject.request_parameters["properties"]["with_cheese"]["type"].should == "boolean"
          subject.request_parameters["properties"]["hold_the_lettuce"]["type"].should == "boolean"
        end
        
        it "produces a valid JSON schema for the response" do
          subject.scaffold_request(request_params)
          subject.request_parameters["properties"].should have(3).keys
          JSON::Validator.validate!(subject.request_parameters, request_params).should be_true
        end
      end
      
      context "when the action is not a scaffold" do
        it "throws an error" do
          expect { resource.action_for("GET", "list", :scaffold => true) }.to raise_exception Fdoc::ActionAlreadyExistsError
        end
      end
    end
  
    describe "#scaffold_response" do
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
        "std_dev" => 1.231
      } }
      
      
      
      context "for succesful responses" do
        before(:each) do 
          subject.should have(0).response_codes
        end
        
        it "adds response codes" do
          subject.scaffold_response({}, "200 OK")
          subject.should have(1).response_codes
          
          subject.scaffold_response({}, "201 Created")
          subject.should have(2).response_codes
        end
        
       it "does not add duplicate response codes" do
          subject.scaffold_response({}, "200 OK")
          subject.should have(1).response_codes

          subject.scaffold_response({}, "200 OK")
          subject.should have(1).response_codes
          
          subject.response_codes.each do |response|
            response["description"].should == "???"
          end
        end

        it "creates properties for top-level keys, and populates them with examples" do
          subject.scaffold_response(response_params, "200 OK")
          subject.response_parameters["type"].should == "object"
          subject.response_parameters["properties"].keys.sort.should == ["nodes", "root_node", "std_dev", "version"]

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
          subject.scaffold_response(response_params, "200 OK")
          subject.response_parameters["properties"]["nodes"]["type"].should == "array"
          subject.response_parameters["properties"]["nodes"]["items"]["type"].should == "object"
          subject.response_parameters["properties"]["nodes"]["items"]["properties"].keys.sort.should == [
            "id", "linked_to","name"]
        end
        
        it "produces a valid JSON schema for the response" do
          subject.scaffold_response(response_params, "200 OK")
          JSON::Validator.validate!(subject.response_parameters, response_params).should be_true
        end
      end
    
      context "for unsuccessful responses" do
        it "adds response codes" do
          subject.should have(0).response_codes
          subject.scaffold_response({}, "400 Bad Request", false)
          subject.should have(1).response_codes    
          subject.scaffold_response({}, "404 Not Found", false)
          subject.should have(2).response_codes
        end
      
        it "does not modify the response_parameters" do
          subject.response_parameters.should be_empty
          subject.scaffold_response(response_params, "403 Forbidden", false)
          subject.response_parameters.should be_empty
        end
      end
      
      context "when the action is not a scaffold" do
        it "throws an error" do
          expect { resource.action_for("GET", "list", :scaffold => true) }.to raise_exception Fdoc::ActionAlreadyExistsError
        end
      end
    end
  end
end