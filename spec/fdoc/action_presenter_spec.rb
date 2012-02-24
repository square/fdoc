require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Fdoc::ActionPresenter do
  describe "::example_from_schema" do
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
    EOS
    example_schema = YAML.load(example_schema_yaml)

    expected_example = {
      "name" => "Bobby Brown",
      "achievements" => ["Most Bugs Squashed"],
      "check_in_count" => 52,
      "email" => nil,
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
      }
    }

    Fdoc::ActionPresenter.example_from_schema(example_schema).should == expected_example
  end
end