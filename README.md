# Client Data Analysis CLI

[![Tests](https://github.com/tob1k/challenge/actions/workflows/test.yml/badge.svg)](https://github.com/tob1k/challenge/actions/workflows/test.yml)

A Ruby command-line application for searching and analyzing client data from JSON datasets. This project demonstrates clean code architecture, comprehensive testing, and modern Ruby development practices.

## Features

- **Name Search**: Search through all clients and return those with names partially matching a given query (case-insensitive)
- **Duplicate Email Detection**: Find clients with duplicate email addresses in the dataset
- **Flexible Dataset Support**: Specify custom dataset files via command-line options
- **Robust Error Handling**: Validates file existence and JSON format before processing

## Installation

1. Clone this repository
2. Install dependencies:

   ```bash
   bundle install
   ```

## Usage

The application provides two main commands:

### Search Names

Search for clients by name (partial, case-insensitive matching):

```bash
# Basic search
bundle exec bin/challenge search "John"

# Using aliases
bundle exec bin/challenge s "Smith"

# Using custom dataset
bundle exec bin/challenge search "Jane" --filename custom_clients.json
bundle exec bin/challenge s "Jane" -f custom_clients.json
```

### Find Duplicate Emails

Find all clients with duplicate email addresses:

```bash
# Basic duplicate detection
bundle exec bin/challenge duplicates

# Using aliases
bundle exec bin/challenge dupe
bundle exec bin/challenge d

# Using custom dataset
bundle exec bin/challenge duplicates --filename custom_clients.json
bundle exec bin/challenge d -f custom_clients.json
```

### Options

- `--filename`, `-f`: Path to the dataset file (default: `clients.json`)
- `--version`, `-v`: Show version number

### Command Aliases

**Search Commands:**

- `search` or `s` - Short aliases for searching by name

**Duplicate Commands:**

- `duplicates`, `dupe`, or `d` - Short aliases for finding duplicates

### Help

```bash
bundle exec bin/challenge help
bundle exec bin/challenge help search
bundle exec bin/challenge help duplicates
bundle exec bin/challenge --version
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
│       └── test.yml          # CI/CD pipeline
├── bin/
│   └── challenge             # Executable script
├── lib/
│   ├── challenge.rb          # Main module loader
│   ├── challenge/
│   │   ├── cli.rb            # Thor CLI interface
│   │   ├── dataset.rb        # Core dataset operations
│   │   └── version.rb        # Version constant
├── spec/
│   ├── spec_helper.rb        # RSpec configuration
│   └── challenge/
│       └── dataset_spec.rb   # Dataset class tests
├── clients.json              # Default dataset
├── Gemfile                   # Dependencies
├── .rubocop.yml              # Code style configuration
└── README.md                 # This file
```

## Architecture Decisions

### Command-Line Interface

- **Thor**: Chosen for its robust CLI framework with built-in help, option parsing, and command structure
- **Modular Design**: Separate CLI from business logic for better testability and maintainability

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
3. **Output Format**: Results are displayed in simple text format; no JSON/CSV export options
4. **Case Sensitivity**: Email comparison is case-sensitive (following RFC standards)

## Future Improvements

Given more time, the following enhancements would be prioritized:

### Architecture Enhancements

- **Streaming JSON Parser**: Use streaming parser for large datasets to reduce memory footprint
- **Database Backend**: Add optional database storage for better performance with large datasets
- **Configuration System**: External configuration files for default settings

### Feature Extensions

- **Dynamic Field Search**: Allow users to specify which field to search (name, email, id, etc.)
- **Advanced Search**: Support regex patterns, multiple field search, and complex queries
- **Export Functionality**: Output results in JSON, CSV, or other formats
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
