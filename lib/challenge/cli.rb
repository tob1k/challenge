# frozen_string_literal: true

module Challenge
  # CLI interface for the Challenge application
  class CLI < Thor
    package_name 'challenge'

    FORMATTERS = {
      'tty' => Formatters::TTYFormatter,
      'csv' => Formatters::CSVFormatter,
      'json' => Formatters::JSONFormatter,
      'xml' => Formatters::XMLFormatter,
      'yaml' => Formatters::YAMLFormatter
    }.freeze

    def self.exit_on_failure?
      true
    end

    class_option :filename,
                 aliases: ['-f'],
                 type: :string,
                 desc: 'Path to the dataset file (required for all commands except version)'

    class_option :output,
                 alises: ['-o'],
                 type: :string,
                 default: 'tty',
                 enum: FORMATTERS.keys,
                 desc: "Output format (#{FORMATTERS.keys.join(', ')})"

    desc 'search QUERY', <<~DESC
      Search through all clients and return those with names
      partially matching a given query
    DESC
    map 's' => :search
    def search(query)
      results = dataset.search_names(query)
      puts formatter.format_search_results(results, query)
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc :duplicates, <<~DESC
      Find out if there are any clients with the same email in
      the dataset, and show those duplicates if any are found
    DESC
    map 'd' => :duplicates
    def duplicates
      duplicates = dataset.duplicate_emails
      puts formatter.format_duplicate_results(duplicates)
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc 'version', 'Show version number'
    map '--version' => :version, '-v' => :version
    def version
      puts formatter.format_version(Challenge::VERSION)
    end

    desc 'generate', 'Generate test dataset'
    option :size, type: :numeric, default: 10_000, desc: 'Number of clients to generate'
    option :force, type: :boolean, desc: 'Overwrite existing files without confirmation'
    map 'g' => :generate
    def generate
      size = options[:size]
      raise Thor::Error, 'Size must be a positive integer' unless size.positive?

      filename = options[:filename] || "clients_#{size}.json"

      check_overwrite(filename) unless options[:force]

      filename = DatasetGenerator.generate(size, options[:filename])
      puts formatter.format_generation_result(filename, size)
    rescue StandardError => e
      raise Thor::Error, "Failed to generate dataset: #{e.message}"
    end

    private

    def dataset
      filename = options[:filename]

      if filename.nil? || filename.empty?
        raise Thor::Error, <<~MSG
          No dataset file specified. Please provide a dataset file with --filename or -f.

          To get started, you can:
          1. Generate a test dataset: challenge generate --filename my_data.json
          2. Use your own JSON file: challenge search "John" --filename your_data.json

          For help: challenge help
        MSG
      end

      @dataset ||= Dataset.new(filename)
    end

    def formatter
      @formatter ||= begin
        format = options[:output] || 'tty'
        formatter_class = FORMATTERS[format]
        raise Thor::Error, "Unknown format: #{format}" unless formatter_class

        formatter_class.new
      end
    end

    def check_overwrite(filename)
      return unless File.exist?(filename)
      return if yes?("File '#{filename}' already exists. Overwrite?")

      raise Thor::Error, 'Generation cancelled by user'
    end
  end
end
