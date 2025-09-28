# Client Data Analysis CLI

[![RSpec](https://github.com/tob1k/challenge/actions/workflows/test.yml/badge.svg)](https://github.com/tob1k/challenge/actions/workflows/test.yml) [![RuboCop](https://github.com/tob1k/challenge/actions/workflows/rubocop.yml/badge.svg)](https://github.com/tob1k/challenge/actions/workflows/rubocop.yml)

A Ruby command-line application for searching and analyzing client data from JSON datasets. This project demonstrates clean code architecture, comprehensive testing, and modern Ruby development practices with a professional gem packaging approach.

## Features

- **Name Search**: Search through all clients and return those with names matching a given query (case-insensitive, supports regex patterns)
- **Duplicate Email Detection**: Find clients with duplicate email addresses in the dataset
- **Dataset Generation**: Generate realistic test datasets with customizable size and guaranteed duplicates
- **Multiple Output Formats**: Support for TTY, CSV, JSON, XML, and YAML output formats
- **Flexible Dataset Support**: Specify custom dataset files via command-line options
- **Robust Error Handling**: Validates file existence and JSON format before processing
- **Graceful Data Handling**: Safely processes datasets with missing or invalid fields
- **Gem Distribution**: Packaged as a proper Ruby gem for easy installation and distribution

## Installation

### As a Gem (Recommended)

```bash
gem build challenge.gemspec
gem install challenge-1.2.2.gem
```

### For Development

1. Clone this repository
2. Install dependencies:

   ```bash
   bundle install
   ```

## Usage

The application provides three main commands with multiple output format options.

### Search Names

Search for clients by name (case-insensitive, supports regex patterns):

```bash
# Basic search (TTY format - default)
challenge search "John"

# Different output formats
challenge search "John" --format json
challenge search "John" --format csv
challenge search "John" --format xml
challenge search "John" --format yaml

# Regex patterns
challenge search "^John"        # Names starting with "John"
challenge search "Smith$"      # Names ending with "Smith"
challenge search "J.*n"        # Names starting with J and ending with n

# Using aliases
challenge s "Smith"

# Using custom dataset
challenge search "Jane" --filename custom_clients.json
challenge s "Jane" -f custom_clients.json
```

### Find Duplicate Emails

Find all clients with duplicate email addresses:

```bash
# Basic duplicate detection (TTY format - default)
challenge duplicates

# Different output formats
challenge duplicates --format json
challenge duplicates --format csv
challenge duplicates --format xml
challenge duplicates --format yaml

# Using aliases
challenge dupe
challenge d

# Using custom dataset
challenge duplicates --filename custom_clients.json
challenge d -f custom_clients.json
```

### Generate Test Dataset

Generate realistic test datasets with customizable size:

```bash
# Generate default dataset (10,000 clients)
challenge generate

# Generate custom size dataset
challenge generate --size 500

# Using aliases and short options
challenge gen --size 1000

# Generate with custom filename
challenge generate --filename my_dataset.json --size 2000
challenge gen -f my_dataset.json --size 2000

# Force overwrite existing files
challenge generate --force --size 5000
```

### Output Formats

The application supports multiple output formats via the `--format` option:

- **tty** (default): Human-readable terminal output with colors
- **csv**: Comma-separated values with headers
- **json**: Structured JSON output
- **xml**: Well-formed XML with proper escaping
- **yaml**: YAML structured data format

### Options

- `--filename`, `-f`: Path to the dataset file (default: `example/clients.json`)
- `--format`: Output format (tty, csv, json, xml, yaml)
- `--size`: Number of clients to generate (default: 10,000, for generate command only)
- `--force`: Overwrite existing files without confirmation (for generate command only)
- `--version`, `-v`: Show version number

### Command Aliases

**Search Commands:**

- `search` or `s` - Short aliases for searching by name

**Duplicate Commands:**

- `duplicates`, `dupe`, or `d` - Short aliases for finding duplicates

**Generate Commands:**

- `generate` or `gen` - Short aliases for dataset generation

### Help

```bash
challenge help
challenge help search
challenge help duplicates
challenge help generate
challenge --version
```

### Development Usage

For development, you can run commands directly with bundler:

```bash
bundle exec bin/challenge search "John"
bundle exec bin/challenge duplicates --format json
bundle exec bin/challenge generate --size 100
```

## Dataset Format

The application expects JSON files containing an array of client objects with the following structure:

```json
[
  {
    "id": 1,
    "full_name": "John Doe",
    "email": "john.doe@gmail.com"
  },
  {
    "id": 2,
    "full_name": "Jane Smith",
    "email": "jane.smith@yahoo.com"
  }
]
```

Required fields:

- `id`: Unique identifier
- `full_name`: Client's full name
- `email`: Client's email address

## Testing

Run the test suite using RSpec:

```bash
# Run all tests
bundle exec rspec

# Run with verbose output
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/challenge/dataset_spec.rb
```

### Test Coverage

The test suite includes:

- **Happy path scenarios**: Valid searches, duplicate detection
- **Edge cases**: Empty queries, whitespace handling, empty datasets
- **Error scenarios**: Missing files, invalid JSON, malformed data
- **Multiple duplicate scenarios**: Complex email duplication patterns

## Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── test.yml          # RSpec tests pipeline
│       └── rubocop.yml       # RuboCop linting pipeline
├── bin/
│   └── challenge             # Executable script
├── example/
│   └── clients.json          # Sample dataset
├── lib/
│   ├── challenge.rb          # Main module loader
│   ├── challenge/
│   │   ├── cli.rb            # Thor CLI interface
│   │   ├── dataset.rb        # Core dataset operations
│   │   ├── dataset_generator.rb # Test dataset generation
│   │   ├── version.rb        # Version constant
│   │   └── formatters/       # Output formatters
│   │       ├── tty_formatter.rb    # Terminal output
│   │       ├── csv_formatter.rb    # CSV output
│   │       ├── json_formatter.rb   # JSON output
│   │       ├── xml_formatter.rb    # XML output
│   │       └── yaml_formatter.rb   # YAML output
├── spec/
│   ├── spec_helper.rb        # RSpec configuration
│   └── challenge/
│       ├── dataset_spec.rb   # Dataset class tests
│       └── cli_spec.rb       # CLI integration tests
├── Gemfile                   # Dependencies
├── challenge.gemspec         # Gem specification
├── .rubocop.yml              # Code style configuration
└── README.md                 # This file
```

## Architecture Decisions

### Command-Line Interface

- **Thor**: Chosen for its robust CLI framework with built-in help, option parsing, and command structure
- **Modular Design**: Separate CLI from business logic for better testability and maintainability
- **Gem Packaging**: Professional gem distribution with proper gemspec and executable

### Output Formatting

- **Formatter Pattern**: Clean separation of output logic from business logic
- **Multiple Formats**: Support for TTY, CSV, JSON, XML, and YAML outputs
- **DRY Configuration**: Format options driven by a single FORMATTERS constant
- **Extensible Design**: Easy to add new output formats without modifying core logic

### Data Processing

- **Dataset Class**: Encapsulates all dataset operations with clear separation of concerns
- **Eager Loading**: Loads entire dataset into memory for fast repeated operations
- **Validation**: File existence and JSON format validation at initialization

### Error Handling

- **Early Validation**: Dataset file validation occurs at object creation
- **Specific Errors**: Clear error messages for different failure scenarios
- **Graceful Degradation**: Empty results rather than crashes for edge cases

## Known Limitations

1. **Memory Usage**: Current implementation loads entire dataset into memory, which may not scale for very large files
2. **Search Functionality**: Only supports name-based searching; field selection is not dynamic
3. **Case Sensitivity**: Email comparison is case-sensitive (following RFC standards)

## Future Improvements

Given more time, the following enhancements would be prioritized:

### Architecture Enhancements

- **Streaming JSON Parser**: Use streaming parser for large datasets to reduce memory footprint
- **Database Backend**: Add optional database storage for better performance with large datasets
- **Configuration System**: External configuration files for default settings

### Feature Extensions

- **Dynamic Field Search**: Allow users to specify which field to search (name, email, id, etc.)
- **Advanced Search**: Multiple field search and complex queries (regex patterns already supported)
- **REST API**: Web service interface for remote access
- **Caching Layer**: Cache search results for improved performance

### Scalability Considerations

- **Pagination**: Support for paginated results in large datasets
- **Indexing**: Add search indexing for faster query performance
- **Concurrent Processing**: Parallel processing for large dataset operations
- **Cloud Storage**: Support for datasets stored in cloud storage (S3, etc.)

### User Experience

- **Interactive Mode**: REPL-style interface for multiple queries
- **Search Suggestions**: Auto-complete and suggestion features
- **Progress Indicators**: Progress bars for long-running operations
- **Colored Output**: Syntax highlighting and colored output for better readability

## Development

### Adding New Commands

1. Add method to `Challenge::CLI` class in `lib/challenge/cli.rb`
2. Add corresponding functionality to `Challenge::Dataset` class
3. Write comprehensive tests in `spec/challenge/`

### Running Development Commands

```bash
# Load the application in IRB for testing
bundle exec irb -r ./lib/challenge

# Run linting
bundle exec rubocop

# Run both tests and linting (CI simulation)
bundle exec rspec && bundle exec rubocop
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is for demonstration purposes.
