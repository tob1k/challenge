# frozen_string_literal: true

module Challenge
  module Formatters
    class TTYFormatter
      def format_search_results(results, query)
        if results.empty?
          "No clients found matching '#{query}'"
        else
          lines = ["Found #{results.size} client(s) matching '#{query}':"]
          results.each do |client|
            lines << "- #{format_client(client)}"
          end
          lines.join("\n")
        end
      end

      def format_duplicate_results(duplicates)
        if duplicates.empty?
          'No duplicate emails found'
        else
          email_groups = duplicates.group_by { |client| client['email'] }
          lines = ['Found duplicate emails:']
          email_groups.each do |email, clients|
            lines << "\n#{email}:"
            clients.each do |client|
              lines << "  - #{format_client(client)}"
            end
          end
          lines.join("\n")
        end
      end

      def format_generation_result(filename, size)
        "Generated #{size} clients and saved to '#{filename}'"
      end

      def format_version(version)
        "challenge #{version}"
      end

      private

      def format_client(client)
        "#{client['full_name']} <#{client['email']}> \e[90m##{client['id']}\e[0m"
      end
    end
  end
end