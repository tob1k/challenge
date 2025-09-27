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

    desc 'search_names QUERY', <<~DESC
      Search through all clients and return those with names
      partially matching a given query
    DESC
    map 'search' => :search_names, 's' => :search_names
    def search_names(query)
      dataset = Dataset.new(options[:filename])
      results = dataset.search_names(query)

      if results.empty?
        puts "No clients found matching '#{query}'"
      else
        puts "Found #{results.size} client(s) matching '#{query}':"
        results.each do |client|
          puts "- #{client['full_name']} (#{client['email']})"
        end
      end
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc :duplicate_emails, <<~DESC
      Find out if there are any clients with the same email in
      the dataset, and show those duplicates if any are found
    DESC
    map 'duplicates' => :duplicate_emails, 'dupe' => :duplicate_emails, 'd' => :duplicate_emails
    def duplicate_emails
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
            puts "  - #{client['full_name']} (ID: #{client['id']})"
          end
        end
      end
    rescue StandardError => e
      raise Thor::Error, e.message
    end
  end
end
