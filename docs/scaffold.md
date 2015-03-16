# fdoc Scaffolding Example

Given a spec that looks like this:

```ruby
require 'fdoc/spec_watcher'

describe MembersController do
  include Fdoc::SpecWatcher

  context "#list", fdoc: 'members/list' do
    it "lists members scoped to age" do
      get :list, {
        limit: 10,
        older_than: Time.gm(2012,"jun",21,10,40,00)
      }
    end
  end
end
````

And a controller that returns:

```json
{
  "members": [
    {
      "name": "Captain Smellypants",
      "email": "smelly@pants.com",
      "member_since": "2012-01-01 13:00:00 UTC"
    },
    {
      "name": "Charlie Chillax",
      "email": "charlie@bitmyfinger.com",
      "member_since": "2012-05-02 12:12:03 UTC"
    }
  ]
}
```


If we run the associated test with `FDOC_SCAFFOLD=true`, fdoc will dump the below example to `members/list-GET.fdoc` in your fdoc folder. Notice how it leaves lots of `???` for you to fill in, but fairly accurately seems to capture the structure of our simple request. It even populates examples, which make for even better documentation.

```yaml
description: ???
requestParameters:
  properties:
    limit:
      description: ???
      required: ???
      type: integer
      example: 10
    older_than:
      description: ???
      required: ???
      type: string
      format: date-time
      example: 2012-06-21 10:40:00.00 Z
responseParameters:
  properties:
    members:
      description: ???
      required: ???
      type: array
      items:
        description: ???
        required: ???
        type: object
        properties:
          name:
            description: ???
            required: ???
            type: string
            example: Captain Smellypants
          email:
            description: ???
            required: ???
            type: string
            example: smelly@pants.com
          member_since:
            description: ???
            required: ???
            type: string
            example: '2012-01-01 13:00:00 UTC'
responseCodes:
- status: 200
  successful: true
  description: ???
```
