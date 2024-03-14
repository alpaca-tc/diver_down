# Diverdown

`divertdown` is a tool that dynamically analyzes application dependencies and creates a dependency map.
This tool was created to analyze Ruby applications for use in large-scale refactoring such as moduler monolith.

The results of the analysis can be viewed in a browser, allowing you to deepen your architectural considerations while viewing the results.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'diverdown'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_bitmask

## Usage

```ruby
tracer = Diverdown::Trace::Tracer.new(
  # @param target_files [Array<String>, Set<String>, nil] If nil, all files are targeted but slow.
  # List of target files to be analyzed. Usually, gem and other files are excluded and specified.
  target_files: Dir["app/**/*.rb"],
  # @param module_set [Array<String>, Diverdown::Trace::ModuleSet] List of modules to be analyzed.
  # When analyzing a your Rails application, set all classes/modules under app/.
  module_set: [
    'User',
    'Item',
    'Order',
    ...
  ],
  # @param filter_method_id_path [#call, nil] The analysis result outputs the absolute path of the caller. To convert to a relative path, define the conversion logic manually.
  filter_method_id_path: -> (path) { path.remove(Rails.root.to_s) },
  # @param module_finder [#call, nil] Specify the logic to determine which module the source found. diverdown promote moduler monolithization, so such an option exists.
  module_finder: -> (source) { 'OrderSystem' if source.source == 'Order' },
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/diverdown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alpaca-tc/diverdown/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Diverdown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alpaca-tc/diverdown/blob/main/CODE_OF_CONDUCT.md).
