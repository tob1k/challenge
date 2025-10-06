# frozen_string_literal: true

require 'csv'

module Challenge
  module Formatters
    # Formats output as CSV with headers and comments
    class CSVFormatter
      def format_search_results(results, query)
        if results.empty?
          "# No clients found matching '#{query}'"
        else
          lines = ["# Found #{results.size} client(s) matching '#{query}':", csv_header]
          results.each { |client| lines << format_client_csv(client) }
          lines.join("\n")
        end
      end

      def format_duplicate_results(duplicates)
        if duplicates.empty?
          '# No duplicate emails found'
        else
          lines = ['# Found duplicate emails:', csv_header]
          duplicates.each { |client| lines << format_client_csv(client) }
          lines.join("\n")
        end
      end

      def format_generation_result(filename, size)
        "# Generated #{size} clients and saved to '#{filename}'"
      end

      def format_filtered_results(results)
        if results.empty?
          '# No clients matched the rating filter'
        else
          lines = ['# Clients matching rating filter:', filtered_csv_header]
          results.each { |client| lines << format_filtered_client_csv(client) }
          lines.join("\n")
        end
      end

      def format_version(version)
        "# challenge #{version}"
      end

      private

      def csv_header
        'id,full_name,email'
      end

      def format_client_csv(client)
        CSV.generate_line([client['id'], client['full_name'], client['email']]).strip
      end

      def filtered_csv_header
        'id,full_name,email,rating,feedback_comments'
      end

      def format_filtered_client_csv(client)
        rating = client.dig('result', 'rating')
        feedback = feedback_comments(client).join(' | ')
        CSV.generate_line([client['id'], client['full_name'], client['email'], rating, feedback]).strip
      end

      def feedback_comments(client)
        Array(client.dig('result', 'feedback')).filter_map do |entry|
          entry.is_a?(Hash) ? entry['comment'] : entry
        end
      end
    end
  end
end
