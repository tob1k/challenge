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
      dataset = Dataset.new(options[:filename])
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
      dataset = Dataset.new(options[:filename])
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

    private

    def format_client(client)
      "#{client['full_name']} <#{client['email']}> \e[90m##{client['id']}\e[0m"
    end
  end
end
