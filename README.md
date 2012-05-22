# fdoc
## Farnsdocs: Documentation format and verification

High-quality documentation is extremely useful, but maintaining it is often a pain. We aim to create a tool to facilitate easy creation and maintenance of API documentation.

fdoc is named for everybody's favorite, good news-bearing, crotchety old man, Professor Farnsworth.

![Professor Farnsworth](https://github.com/square/fdoc/raw/master/docs/farnsworth.png)

### Usage

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

### Example

`.fdoc` files are YAML files based on JSON schema to describe API endpoints.

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
    

### Goals

 - As a client engineer, I want to be able to document an API and keep it up to date
 - The server engineers want to be able to test their implementations
 - The documentation should be as close to the code as possible, it should live in the same repository (like specs)
   - Branches, reviews, and merges are the appropriate way to update the docs
   - Experimental drafts should just live on branches and never get merged into master
 - Specification alone is not enough, there needs to be room for discussion

### Feedback

Since fdoc is built on top of JSON schemas, all the hard work of verifiying that inputs conform their respective schemas is done by a [JSON schema gem](https://github.com/hoxworth/json-schema).

To make feedback more valuable, the request and response consumption methods will modify schemas to set `additionalProperties` to `false` unless specified. This gives the desired behavior of throwing an error when a new property is detected in the schema to verify, indicating the documentation needs updating.

