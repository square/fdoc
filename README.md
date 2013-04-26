# fdoc: Documentation format and verification

High-quality documentation is extremely useful, but maintaining it is often a pain. We aim to create a tool to facilitate easy creation and maintenance of API documentation.

In a Rails or Sinatra app, fdoc can help document an API as well as verify that requests and responses adhere to their appropriate schemata.

Outside a Rails or Sinatra app, fdoc can provide a common format for API documentation, as well as the ability to generate basic HTML pages for humans to consume.

fdoc is short for Farnsdocs. They are named for everybody's favorite, good news-bearing, crotchety old man, Professor Farnsworth.

![Professor Farnsworth][github_img]

## Usage

### In a Rails app

Add fdoc to your Gemfile.

    gem 'fdoc'

Tell fdoc where to look for `.fdoc` files. By default, fdoc will look in `docs/fdoc`, but you can change this behavior to look anywhere. This fits best in something like a spec\_helper file.

```ruby
require 'fdoc'

Fdoc.service_path = "path/to/your/fdocs"
```

fdoc is built to work around controller specs in rspec, and provides `Fdoc::SpecWatcher` as a mixin. Make sure to include it *inside* your top level describe.

```ruby
require 'fdoc/spec_watcher'

describe MembersController do
  include Fdoc::SpecWatcher
  # ...
end
```

To enable fdoc for an endpoint, add the `fdoc` option with the path to the endpoint. fdoc will intercept all calls to `get`, `post`, `put`, and `delete` and verify those parameters accordingly.

```ruby
context "#show", :fdoc => 'members/list' do
  # ...
end
```

fdoc also has a scaffolding mode, where it attemps to infer the schema of a request based on sample responses. The interface is exactly the same as verifying, just set the environment variable `FDOC_SCAFFOLD=true`.

    FDOC_SCAFFOLD=true bundle exec rspec spec/controllers

For more information on scaffolding, please see the more in-depth [fdoc scaffolding example][github_scaffold].

### In a Sinatra app

Add fdoc to your Gemfile.

    gem 'fdoc'

Tell fdoc where to look for `.fdoc` files. By default, fdoc will look in `docs/fdoc`, but you can change this behavior to look anywhere. This fits best in something like a spec\_helper file.

```ruby
require 'fdoc'

Fdoc.service_path = "path/to/your/fdocs"
```

fdoc is built to work around your Sinatra app specs in rspec, and provides `Fdoc::SpecWatcher` as a mixin. Make sure to include it *inside* your top level describe.

```ruby
require 'fdoc/spec_watcher'

describe Sinatra::Application do
  include Rack::Test::Methods
  include Fdoc::SpecWatcher

  def app
    Sinatra::Application
  end
end
```

### Outside a Rails App

fdoc provides the `fdoc convert` script to transform a directory of `.fdoc` files into more human-readable HTML.

In this repo, try running:

    bin/fdoc convert ./spec/fixtures --output=./html

## Example

`.fdoc` files are YAML files based on [JSON schema][json_schema] to describe API endpoints. They derive their endpoint path and verb from their filename.

- For more information on fdoc file naming conventions, please see the [fdoc file conventions guide][github_files].
- For more information on how fdoc uses JSON schema, please see the [json schema usage document][github_json].

Here is `docs/fdoc/members/list-GET.fdoc`:

```yaml
description: The list of members.
requestParameters:
  properties:
    limit:
      type: integer
      required: no
      default: 50
      description: Limits the number of results returned, used for paging.
responseParameters:
  properties:
    members:
      type: array
      items:
        title: member
        description: Representation of a member
        type: object
        properties:
          name:
            description: Member's name
            type: string
            required: yes
            example: Captain Smellypants
responseCodes:
- status: 200 OK
  successful: yes
  description: A list of current members
- status: 400 Bad Request
  successful: no
  description: Indicates malformed parameters
```

If we run a test against our members controller with an undocumented parameter, `offset`, we'll get an error.

Our spec file, `spec/controllers/members_controller_spec.rb` looks like:

```ruby
require 'fdoc/spec_watcher'

describe MembersController do
  context "#show", :fdoc => "members/list" do
    it "can take an offset" do
      get :show, {
        :offset => 5
      }
    end
  end
end
```

We run:

    bundle exec rspec spec/controllers/members_controller_spec.rb

And since `offset` is undocumented, fdoc will fail the test:

    Failures:

      1) MembersController#show can take an offset
         Failure/Error: get :show, { :offset => 5 }
         JSON::Schema::ValidationError:
           The property '#/' contains additional properties ["offset"] outside of the schema when none are allowed in schema 8fcac6c4-294b-56a2-a3de-9342e2e729da#
         # ./spec/controllers/members_controller_spec.rb:5:in `block (3 levels) in <top (required)>'

If we run the same spec in scaffold mode, it passes and fdoc will write changes to the correspoding `.fdoc` file:

    FDOC_SCAFFOLD=true bundle exec spec/controllers/members_controller_spec.rb

The diff looks like:

```diff
diff --git a/docs/fdoc/members/list-GET.fdoc b/docs/fdoc/members/list-GET.fdoc b2e3656..dfa363a 100644
--- a/docs/fdoc/members/list-GET.fdoc
+++ b/docs/fdoc/members/list-GET.fdoc
+    offset:
+      description: ???
+      required: ???
+      type: integer
+      example: 5
```

Notice how it infers a type, and copies an example, but leaves description and required blank. These fields are best left to humans to decide.


## Goals

- Client engineers should be able to participate in documenting an API and
  keeping it up to date.
- Server engineers should be able to test their implementations.
- The documentation should be as close to the code as possible.
  - Branches, reviews, and merges are the appropriate way to update the docs.
  - Experimental drafts should just live on branches and never get
    merged into master.
- Specification alone is not enough, there needs to be room for discussion.

## Contributing

Just fork and make a pull request! You will need to sign the [Individual Contributor License Agreement (CLA)][contrib_license] before we can merge your code.




[github_img]: https://github.com/square/fdoc/raw/master/docs/farnsworth.png
[github_scaffold]: https://github.com/square/fdoc/blob/master/docs/scaffold.md
[github_json]: https://github.com/square/fdoc/blob/master/docs/json_schema.md
[github_files]: https://github.com/square/fdoc/blob/master/docs/files.md

[json_schema]: http://json-schema.org/
[contrib_license]: https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1
