# frozen_string_literal: true

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
                 default: 'clients.json',
                 desc: 'Path to the dataset file'

    desc 'search QUERY', <<~DESC
      Search through all clients and return those with names
      partially matching a given query
    DESC
    map 's' => :search
    def search(query)
      results = dataset.search_names(query)

      if results.empty?
        puts "No clients found matching '#{query}'"
      else
        puts "Found #{results.size} client(s) matching '#{query}':"
        results.each do |client|
          puts "- #{format_client(client)}"
        end
      end
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

      if duplicates.empty?
        puts 'No duplicate emails found'
      else
        email_groups = duplicates.group_by { |client| client['email'] }
        puts 'Found duplicate emails:'
        email_groups.each do |email, clients|
          puts "\n#{email}:"
          clients.each do |client|
            puts "  - #{format_client(client)}"
          end
        end
      end
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc 'version', 'Show version number'
    map '--version' => :version, '-v' => :version
    def version
      puts "challenge #{Challenge::VERSION}"
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
      puts "Dataset generated: #{filename}"
    rescue StandardError => e
      raise Thor::Error, "Failed to generate dataset: #{e.message}"
    end

    private

    def dataset
      @dataset ||= Dataset.new(options[:filename])
    end

    def format_client(client)
      "#{client['full_name']} <#{client['email']}> \e[90m##{client['id']}\e[0m"
    end

    def check_overwrite(filename)
      return unless File.exist?(filename)
      return if yes?("File '#{filename}' already exists. Overwrite?")

      raise Thor::Error, 'Generation cancelled by user'
    end
  end
end
