# DiverDown

`DiverDown` is a tool designed to dynamically analyze application dependencies and generate a comprehensive dependency map. It is particularly useful for analyzing Ruby applications, aiding significantly in large-scale refactoring projects or transitions towards a modular monolith architecture.

## Features

- **Dependency Mapping**: Analyze and generate an application dependencies.
- **Module Categorization**: Organizes file-by-file associations into specific groups, facilitating deeper modular monolith architectural analysis and understanding.

## Getting Started

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

The `DiverDown::Trace` module analyzes the execution of Ruby code and outputs the results as `DiverDown::Definition` objects.

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

**Options**

When analyzing user applications, it is recommended to specify the option.

|name|type|description|example|default|
| --- | --- | --- | --- | --- |
| `module_set` | Hash{ <br>  modules: Array<Module, String> \| Set<Module, String> \| nil,<br>  paths: Array\<String> \| Set\<String> \| nil <br>}<br>\| DiverDown::Trace::ModuleSet | Specify the class/module to be included in the analysis results.<br><br>If you know the module name:<br>`{ modules: [ModA, ModB] }`<br><br>If you know module path:<br>`{ paths: ['/path/to/rails/app/models/mod_a.rb'] }` | `{ paths: Dir["app/**/*.rb"] }` | `nil`. All class/modul are target. |
| `caller_paths` | `Array<String> \| nil` | Specifies a list of allowed paths as caller paths. By specifying the user application path in this list of paths and excluding paths under the gem, the caller path is identified back to the user application path. | `Dir["app/**/*.rb"]` | `nil`. All paths are target. |
| `filter_method_id_path` | `#call \| nil` | lambda to convert the caller path. | `->(path) { path.remove(Rails.root) }` | `nil`. No conversion. |

**Example**

```ruby
# Your rails application paths
application_paths = [
  *Dir['app/**/*.rb'], 
  *Dir['lib/**/*.rb'],
].map { File.expand_path(_1) }

ignored_application_paths = [
  'app/models/application_record.rb',
].map { File.expand_path(_1) }

module_set = DiverDown::Trace::ModuleSet.new(modules: modules - ignored_modules)

filter_method_id_path = ->(path) { path.remove("#{Rails.root}/") }

tracer = DiverDown::Trace::Tracer.new(
  caller_paths: application_paths,
  module_set: {
    paths: (application_paths - ignored_application_paths)
  },
  filter_method_id_path:
)

definition = tracer.trace do
  # do something
end
```

#### Output Results

The analysis results are intended to be saved to a specific directory in either `.json` or `.yaml` format. These files are compatible with `DiverDown::Web`, which can read and display the results.

```ruby
dir = 'tmp/diver_down'

definition = tracer.trace do
  # do something
end

File.write(File.join(dir, "#{definition.title}.json"), definition.to_h.to_json)
File.write(File.join(dir, "#{definition.title}.yaml"), definition.to_h.to_yaml)
```

### `DiverDown::Web`

View the analysis results in a browser.

This gem is specifically designed to analyze large applications with a modular monolithic architecture. It allows users to categorize each analyzed file into specified modules directly through the web interface.

- `--definition-dir` Specifies the directory where the analysis results are stored.
- `--module-store-path` Designates a path to save the results that include details on which module each file belongs to. If this option is not specified, the results will be temporarily stored in a default temporary file.

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

### Development `DiverDown::Web`

If you want to develop `DiverDown::Web` locally, set up a server for development.

```
# Start server for frontend
$ pnpm install
$ pnpm run dev

# Start server for backend
$ bundle install
$ DIVER_DOWN_DIR=/path/to/definitions_dir DIVER_DOWN_MODULE_STORE=/path/to/module_store.yml bundle exec puma
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/diver_down. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DiverDown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alpaca-tc/diver_down/blob/main/CODE_OF_CONDUCT.md).
