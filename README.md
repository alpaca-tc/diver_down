# DiverDown

`divertdown` is a tool that dynamically analyzes application dependencies and creates a dependency map.
This tool was created to analyze Ruby applications for use in large-scale refactoring such as moduler monolith.

The results of the analysis can be viewed the dependency map graph, and and since the file-by-file association can be categorized into specific groups, you can deepen your architectural consideration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'diver_down'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install diver_down

## Usage

`divert_down` is mainly divided into the `DiverDown::Trace` for dynamic analysing ruby code, and the `DiverDown::Web` for viewing the result on the browser.

### `DiverDown::Trace`

Analyzes the processing of ruby code and outputs the analysis results as `DiverDown::Definition`.

```ruby
tracer = DiverDown::Trace::Tracer.new

# Analyze the processing in the block.
definition = tracer.trace do
  # do something
end

# Or, analyze the processing without block.
session = tracer.new_session

session.start
# do something
session.stop

definition = session.definition
```

```ruby
# Analysis results can be titled.
# And if specified the `definition_group`, the results can be grouped when viewed in a browser.
tracer = DiverDown::Trace::Tracer.new

tracer.trace(title: 'title', definition_group: 'group name') do
  # do something
end
```

The analysis results should be output to a specific directory.
Files saved in `.msgpack`, `.json`, or `.yaml` can be read by `DiverDown::Web`.

```ruby
dir = 'tmp/diver_down'

definition = tracer.trace do
  # do something
end

File.binwrite(File.join(dir, "#{definition.title}.msgpack"), definition.to_msgpack)
File.write(File.join(dir, "#{definition.title}.json"), definition.to_h.to_json)
File.write(File.join(dir, "#{definition.title}.yaml"), definition.to_h.to_yaml)
```

**Options**

TODO

### `DiverDown::Web`

View the analysis results in a browser.

This gem is designed to consider large application with a modular monolithic architecture.
Each file in the analysis can be specified to belong to a module you specify on the browser.

- `--definition-dir` specifies the directory where the analysis results are stored.
- `--module-store-path` will store the results specifying which module each file belongs to. If not specified, the specified results are stored in tempfile.

```sh
bundle exec diver_down_web --definition-dir tmp/diver_down --module-store-path tmp/module_store.yml
open http://localhost:8080
```

## Development

1. Checking out the repo `git clone https://github.com/alpaca-tc/diver_down`
1. Install dependencies.
  - [Install pnpm](https://pnpm.io/installation)
  - [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/)
  - `pnpm install`
  - `bundle install`
1. Run the tests/static code analyzer.
  - Ruby: `bundle exec rspec`, `bundle exec rubocop`
  - TypeScript: `pnpm run test`, `pnpm run lint`

### Development DiverDown::Web

If you want to develop `DiverDown::Web` locally, set up a server for development.

```
# Start server for frontend
$ pnpm install
$ pnpm run dev

# Start server for backend
$ bundle install
# DIVER_DOWN_DIR specifies the directory where the analysis results are stored.
# DIVER_DOWN_MODULE_STORE specifies a yaml file that defines which module the file belongs to, but this file is newly created, so it works even if the file does not exist.
$ DIVER_DOWN_DIR=/path/to/definitions_dir DIVER_DOWN_MODULE_STORE=/path/to/module_store.yml bundle exec puma
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/diver_down. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DiverDown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).
