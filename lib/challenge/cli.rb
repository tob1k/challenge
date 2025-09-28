# frozen_string_literal: true

require_relative 'formatters/tty_formatter'
require_relative 'formatters/csv_formatter'
require_relative 'formatters/json_formatter'
require_relative 'formatters/xml_formatter'

module Challenge
  # CLI interface for the Challenge application
  class CLI < Thor
    package_name 'challenge'

    def self.exit_on_failure?
      true
    end

    class_option :filename,
                 aliases: ['-f'],
                 type: :string,
                 default: 'example/clients.json',
                 desc: 'Path to the dataset file'

    class_option :format,
                 type: :string,
                 default: 'tty',
                 enum: %w[tty csv json xml],
                 desc: 'Output format (tty, csv, json, xml)'

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
    map 'dupe' => :duplicates, 'dupes' => :duplicates, 'd' => :duplicates
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
    map 'gen' => :generate
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
      @dataset ||= Dataset.new(options[:filename])
    end

    def formatter
      @formatter ||= case options[:format] || 'tty'
                     when 'tty'
                       Formatters::TTYFormatter.new
                     when 'csv'
                       Formatters::CSVFormatter.new
                     when 'json'
                       Formatters::JSONFormatter.new
                     when 'xml'
                       Formatters::XMLFormatter.new
                     else
                       raise Thor::Error, "Unknown format: #{options[:format]}"
                     end
    end

    def check_overwrite(filename)
      return unless File.exist?(filename)
      return if yes?("File '#{filename}' already exists. Overwrite?")

      raise Thor::Error, 'Generation cancelled by user'
    end
  end
end
