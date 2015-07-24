# Step-by-Step quick guide.

_Note: This guide was designed with RSpec in mind_

1. Add `fdoc` to `Gemfile`  
  ```ruby
  gem "fdoc"
  ```  
2. Add in `rails_helper.rb` and after the `include rspec/rails` line:
  ```ruby
  require 'fdoc/spec_watcher'`
  ```
3. `include Fdoc::SpecWatcher` to every controller spec imidiatly after the main describe block, it could look something like this:

  ```ruby
  RSpec.describe Api::V1::CommentsController, type: :controller do
  include Fdoc::SpecWatcher

  end
  ```

4. On your `describe` block add `fdoc: 'comments/index'` (where _comments_ is the controller and _index_ the action). It could look something like:

  ```ruby
  describe "#index", fdoc: 'comments/index' do
    ...
  end
  ```

5. Create a folder `docs/fdoc` in root (same level as `app`).

6. Now you can run:
```bash
FDOC_SCAFFOLD=true bundle exec rspec spec/controllers
```
This is going to create a series of .fdoc files trying to reproduce your controllers’ structure based in your tests, in a way to makes easier API documentation.

### How to convert those .fdoc files to .html?

To convert from .fdoc to .html, you'll need to add the next files and folders into your project.

1. [bin/fdoc][bin fdoc]
1. [fdoc/cli.rb][fdoc clirb]
1. [fdoc/meta_service.rb][fdoc meta service]
1. [fdoc/service.rb][fdoc service]

Now, just run the following script to to convert your files.
```bash
bin/fdoc convert ./docs/fdoc --output=./html
```

You will find those .html files in a folder called `html` in the root of your Rails app.

### The end.

[bin fdoc]: https://github.com/square/fdoc/blob/master/bin/fdoc
[fdoc clirb]: https://github.com/square/fdoc/blob/master/lib/fdoc/cli.rb
[fdoc meta service]: https://github.com/square/fdoc/blob/master/lib/fdoc/meta_service.rb
[fdoc service]: https://github.com/square/fdoc/blob/master/lib/fdoc/service.rb
