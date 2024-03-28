# DiverDown

`divertdown` is a tool that dynamically analyzes application dependencies and creates a dependency map.
This tool was created to analyze Ruby applications for use in large-scale refactoring such as moduler monolith.

The results of the analysis can be viewed in a browser, allowing you to deepen your architectural considerations while viewing the results.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'diver_down'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_bitmask

## Usage

```ruby
tracer = DiverDown::Trace::Tracer.new(
  # @param target_files [Array<String>, Set<String>, nil] If nil, all files are targeted but slow.
  # List of target files to be analyzed. Usually, gem and other files are excluded and specified.
  target_files: Dir["app/**/*.rb"],
  # @param module_set [Array<String>, DiverDown::Trace::ModuleSet] List of modules to be analyzed.
  # When analyzing a your Rails application, set all classes/modules under app/.
  module_set: [
    'User',
    'Item',
    'Order',
    ...
  ],
  # @param filter_method_id_path [#call, nil] The analysis result outputs the absolute path of the caller. To convert to a relative path, define the conversion logic manually.
  filter_method_id_path: -> (path) { path.remove(Rails.root.to_s) },
  # @param module_finder [#call, nil] Specify the logic to determine which module the source found. diver_down promote moduler monolithization, so such an option exists.
  module_finder: -> (source) { 'OrderSystem' if source.source == 'Order' },
)
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

### Development DiverDown::Web

```
# Start vite
$ pnpm install
$ pnpm run dev

# Start rack
$ bundle install
$ DIVERDOWN_DIR=/path/to/definitions_dir bundle exec puma
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/diver_down. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DiverDown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).
