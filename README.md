# fdoc: Documentation format and verification

High-quality documentation is extremely useful, but maintaining it is often a pain. We aim to create a tool to facilitate easy creation and maintenance of API documentation.

In a Rails app, fdoc can help document an API as well as verify that requests and responses adhere to their appropriate schemata.

Outside a Rails app, fdoc can provide a common format for API documentation, as well as the ability to generate basic HTML pages for humans to consume.

fdoc is short for Farnsdocs. They are named for everybody's favorite, good news-bearing, crotchety old man, Professor Farnsworth.

![Professor Farnsworth][github_img]

## Usage

### In a Rails app

Add fdoc to your Gemfile.

    gem 'fdoc'

Tell fdoc where to look for .fdoc files. By default, fdoc will look in `docs/fdoc`, but you can change this behavior to look anywhere. This fits best in something like a spec\_helper file.

    require 'fdoc'

    Fdoc.service_path = "path/to/your/fdocs"

fdoc is built to work around controller specs in rspec, and provides `Fdoc::SpecWatcher` as a mixin. Make sure to include it *inside* your top level describe.

    require 'fdoc/spec_watcher'

    describe MembersController do
      include Fdoc::SpecWatcher
      ...
    end

To enable fdoc for an endpoint, add the `fdoc` option with the path to the endpoint. fdoc will intercept all calls to `get`, `post`, `put`, and `delete` and verify those parameters accordingly.

    context "#show", :fdoc => 'members/list' do
      ..
    end

fdoc also has a scaffolding mode, where it attemps to infer the schema of a request based on sample responses. The interface is exactly the same as verifying, just set the environment variable `FDOC_SCAFFOLD=true`.

    FDOC_SCAFFOLD=true bundle exec rspec spec/controllers

For more information on scaffolding, please see the more in-depth [fdoc scaffolding example][github_scaffold].

### Outside a Rails App

fdoc provides the `fdoc_to_html` script to transform a directory of `.fdoc` files into more human-readable HTML.

In this repo, try running:

    bin/fdoc_to_html spec/fixtures html

## Example

`.fdoc` files are YAML files based on [JSON schema][json_schema] to describe API endpoints. They derive their endpoint path and verb from their filename.

- For more information on fdoc file naming conventions, please see the [fdoc file conventions guide][github_files].
- For more information on how fdoc uses JSON schema, please see the [json schema usage document][github_json].

Here is `members/list-POST.fdoc`:

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


## Goals

 - As a client engineer, I want to be able to document an API and keep it up to date
 - The server engineers want to be able to test their implementations
 - The documentation should be as close to the code as possible, it should live in the same repository (like specs)
   - Branches, reviews, and merges are the appropriate way to update the docs
   - Experimental drafts should just live on branches and never get merged into master
 - Specification alone is not enough, there needs to be room for discussion

## Contributing

Just fork and make a pull request! You will need to sign the [Individual Contributor License Agreement (CLA)][contrib_license] before we can merge your code.




[github_img]: https://github.com/square/fdoc/raw/master/docs/farnsworth.png
[github_scaffold]: https://github.com/square/fdoc/blob/master/docs/scaffold.md
[github_json]: https://github.com/square/fdoc/blob/master/docs/json_schema.md
[github_files]: https://github.com/square/fdoc/blob/master/docs/files.md

[json_schema]: http://json-schema.org/
[contrib_license]: https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1
