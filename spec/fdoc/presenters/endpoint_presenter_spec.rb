require 'spec_helper'
require 'nokogiri'

describe Fdoc::EndpointPresenter do
  subject {
    described_class.new(endpoint)
  }

  let (:test_service) { Fdoc::Service.new('spec/fixtures') }
  let (:endpoint) { Fdoc::Endpoint.new("spec/fixtures/members/list/GET.fdoc", test_service) }

  context "#to_html" do
    it "should generate valid HTML" do
      html = subject.to_html

      expect {
        Nokogiri::HTML(html) { |config| config.strict }
      }.to_not raise_exception
    end
  end

  context "#to_markdown" do
    it "should generate markdown" do
      markdown = subject.to_markdown
      markdown.should include "# GET spec&#8203;/fixtures&#8203;/members&#8203;/list"
    end
  end

  context "#example_from_schema" do
    example_schema_yaml = <<-EOS
    properties:
      name:
        type: string
        example: Bobby Brown
      achievements:
        type: array
        items:
          type: string
          example: Most Bugs Squashed
      check_in_count:
        type: integer
        example: 52
      friends:
        type: array
        items:
          properties:
            name:
              type: string
              example: Freddy Friend
            id:
              type: integer
              example: 12345
      email:
        type: string
      address:
        properties:
          street_number:
            type: integer
            example: 1234
          street_name:
            type: string
            example: Main St.
          state:
            type: string
            example: CA
          zip:
            type: integer
            example: 91234
      homepage_url:
        type: ['string', 'null']
        format: uri
        example: http://my.website.com
    EOS
    example_schema = YAML.load(example_schema_yaml)

    expected_example = {
      "name" => "Bobby Brown",
      "achievements" => ["Most Bugs Squashed"],
      "check_in_count" => 52,
      "email" => "",
      "friends" => [
        {
          "name" => "Freddy Friend",
          "id" => 12345
        }
      ],
      "address" => {
        "street_number" => 1234,
        "street_name" => "Main St.",
        "state" => "CA",
        "zip" => 91234
      },
      "homepage_url" => "http://my.website.com"
    }

    it "should generate an example response from the contents of the schema" do
      subject.example_from_schema(example_schema).should == expected_example
    end
  end
end
