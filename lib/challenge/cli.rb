# frozen_string_literal: true

module Challenge
  # CLI interface for the Challenge application
  class CLI < Thor
    package_name 'challenge'

    class_option :dataset,
                 aliases: ['-d'],
                 type: :string,
                 default: 'clients.json',
                 desc: 'Path to the dataset file'

    desc :search_names, <<~DESC
      Search through all clients and return those with names
      partially matching a given query
    DESC
    option :query, aliases: ['-q'], type: :string, required: true, desc: 'Search query'
    def search_names
      dataset = Dataset.new(options[:dataset])
      results = dataset.search_names(options[:query])

      if results.empty?
        puts "No clients found matching '#{options[:query]}'"
      else
        puts "Found #{results.size} client(s) matching '#{options[:query]}':"
        results.each do |client|
          puts "- #{client['full_name']} (#{client['email']})"
        end
      end
    end

    desc :duplicate_emails, <<~DESC
      Find out if there are any clients with the same email in
      the dataset, and show those duplicates if any are found
    DESC
    def duplicate_emails
      dataset = Dataset.new(options[:dataset])
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
    end
  end
end
