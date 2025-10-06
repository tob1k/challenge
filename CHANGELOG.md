# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-10-06

### Added
- `filter_by_rating` command to filter clients by minimum rating threshold
- Support for optional `result` field in client data (rating and feedback)
- Syntax highlighting for search query matches in TTY output format
- Generated datasets now include realistic rating and feedback data
- All output formatters (TTY, CSV, JSON, XML, YAML) now support rating and feedback fields

### Changed
- Updated all formatters to display rating and feedback information for search and duplicates commands
- Enhanced TTY formatter with bold yellow highlighting for search matches
- Dataset generator now creates clients with random ratings (2.0-5.0) and 0-3 feedback comments

## [1.2.6] - 2024-09-28

### Added
- Automated GitHub Packages publishing pipeline
- GitHub release creation with gem attachments
- Comprehensive CI/CD documentation

### Changed
- Switched from RubyGems to GitHub Packages for gem distribution
- Updated installation instructions for GitHub Packages

### Fixed
- GitHub Actions workflow permissions for package publishing

## [1.2.5] - 2024-09-28

### Added
- Reusable GitHub Actions workflows to eliminate duplication
- Automated release workflow triggered by version tags

### Changed
- Release workflow now reuses existing test and RuboCop workflows

## [1.2.4] - 2024-09-28

### Added
- Professional gem specification file (challenge.gemspec)
- Gem packaging and distribution support
- Runtime dependencies properly declared (csv, thor)

### Changed
- Project structure updated to support gem distribution
- Version alignment between gemspec and RuboCop configuration

## [1.2.3] - 2024-09-28

### Added
- Multiple output formatters: CSV, JSON, XML, YAML
- TTY formatter with colored output and improved readability
- Formatter pattern architecture for clean separation of concerns
- Format validation with enum support in CLI

### Changed
- Extracted all output logic from CLI to dedicated formatter classes
- Applied DRY principles to format configuration
- Enhanced user experience with format-specific output styling

## [1.2.2] - 2024-09-28

### Added
- YAML output formatter
- Comprehensive formatter test coverage

### Fixed
- RuboCop violations in formatter implementations

## [1.2.1] - 2024-09-28

### Added
- Dataset generation functionality with customizable size
- Guaranteed duplicate email generation for testing
- Force overwrite option for dataset generation
- Integration tests for CLI commands

### Changed
- Improved dataset generation performance by removing Faker dependency
- Streamlined duplicate generation algorithm

### Fixed
- Gemfile dependencies and bundle configuration
- GitHub Actions badge rendering

## [1.2.0] - 2024-09-28

### Added
- Comprehensive GitHub Actions CI/CD pipeline
- RSpec testing across multiple Ruby versions (3.1-3.4)
- RuboCop linting with zero violations tolerance
- Separate workflow badges for testing and code quality

### Changed
- Enhanced error handling with proper CLI status codes
- Improved command aliases and user experience
- Updated project documentation

### Fixed
- Ruby version compatibility issues
- Test matrix configuration

## [1.1.0] - 2024-09-28

### Added
- Command-line aliases for improved usability (s, d, dupe, gen)
- Version command with proper CLI integration
- Colored output with low-contrast ID display
- Graceful error handling for missing datasets

### Changed
- Refactored CLI command structure for better UX
- Improved exception handling and user feedback

### Fixed
- File existence checking logic
- Unnecessary instance variable usage

## [1.0.0] - 2024-09-28

### Added
- Initial project setup with Thor CLI framework
- Name search functionality with regex pattern support
- Duplicate email detection across datasets
- Robust JSON file validation and error handling
- Comprehensive RSpec test suite with edge cases
- Professional project structure and documentation

### Features
- Search through clients by name (case-insensitive)
- Find duplicate email addresses in datasets
- Flexible dataset file specification
- Comprehensive error handling for malformed data
- Clean separation between CLI and business logic
