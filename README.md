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

### Quick Install (Recommended)

Download the latest `.gem` file from [Releases](https://github.com/tob1k/challenge/releases) and install locally:

```bash
gem install challenge-1.2.10.gem
```

### For Development

```bash
git clone https://github.com/tob1k/challenge.git
cd challenge
bundle install
```

## Usage

### Quick Start

```bash
# 1. Generate test data
challenge generate -f data.json --size 1000

# 2. Search for clients
challenge search "John" -f data.json

# 3. Find duplicate emails
challenge duplicates -f data.json
```

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `generate` | Create test dataset | `challenge generate -f data.json --size 1000` |
| `search` | Find clients by name | `challenge search "John" -f data.json` |
| `duplicates` | Find duplicate emails | `challenge duplicates -f data.json` |
| `version` | Show version | `challenge version` |

### Output Formats

Add `--format FORMAT` to any command:

```bash
challenge search "John" -f data.json --format json
challenge duplicates -f data.json --format csv
```

**Available formats:** `tty` (default), `csv`, `json`, `xml`, `yaml`

### Advanced Usage

```bash
# Regex search patterns
challenge search "^John" -f data.json          # Names starting with "John"
challenge search "Smith$" -f data.json         # Names ending with "Smith"

# Short aliases
challenge s "John" -f data.json                # search
challenge d -f data.json                       # duplicates
challenge gen -f data.json --size 500          # generate

# Large datasets
challenge generate -f big_data.json --size 50000 --force
```

### Help

```bash
challenge help
challenge --version
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
│       ├── rubocop.yml       # RuboCop linting pipeline
│       └── release.yml       # Automated gem publishing
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
├── CHANGELOG.md              # Release history and changes
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

### CI/CD Pipeline

- **Automated Testing**: Multi-version Ruby testing (3.1-3.4) on every push and PR
- **Code Quality**: RuboCop linting with zero violations tolerance
- **Automated Releases**: Tag-triggered publishing to GitHub Packages
- **Reusable Workflows**: DRY principle applied to GitHub Actions workflows
- **Zero-Config Publishing**: No external secrets or manual configuration required

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

### Releasing

The project includes automated release workflows with full CI/CD pipeline:

1. **Create a release tag**:

   ```bash
   # Update version in lib/challenge/version.rb first
   git add lib/challenge/version.rb
   git commit -m "Bump version to 1.2.5"
   git tag v1.2.5
   git push origin main
   git push origin v1.2.5
   ```

2. **Automated CI/CD process**:
   - ✅ **Quality Gates**: Runs RSpec tests across Ruby versions 3.1-3.4 and RuboCop linting
   - ✅ **Build**: Compiles the gem from source
   - ✅ **Publish**: Publishes to GitHub Packages registry
   - ✅ **Release**: Creates GitHub release with changelog and gem attachment
   - ✅ **Zero-config**: Uses built-in `GITHUB_TOKEN` with appropriate permissions

**Release Features:**

- 🔄 **Reusable workflows**: Leverages existing test and lint workflows to avoid duplication
- 🛡️ **Quality assurance**: Only publishes if all tests and linting pass
- 📦 **Multiple distribution**: Available via GitHub Packages and direct download
- 🏷️ **Semantic versioning**: Tag-based releases with automatic version detection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is for demonstration purposes.
