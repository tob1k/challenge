# frozen_string_literal: true

module Challenge
  module Formatters
    # Formats output for terminal display with colors and human-readable text
    class TTYFormatter
      def format_search_results(results, query)
        if results.empty?
          "No clients found matching '#{query}'"
        else
          lines = ["Found #{results.size} client(s) matching '#{query}':"]
          results.each do |client|
            lines << "- #{format_client(client, query)}"
            lines.concat(format_client_details(client))
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
              format_client_details(client).each { |detail| lines << "    #{detail}" }
            end
          end
          lines.join("\n")
        end
      end

      def format_generation_result(filename, size)
        "Generated #{size} clients and saved to '#{filename}'"
      end

      def format_filtered_results(results)
        return 'No clients matched the rating filter' if results.empty?

        lines = []
        results.each do |client|
          lines << format_client(client)

          rating = client.dig('result', 'rating')
          lines << "Rating #{rating}" if rating

          feedback_comments = extract_feedback_comments(client)
          lines << feedback_comments.map { |comment| "\"#{comment}\"" }.join(', ') if feedback_comments.any?
          lines << ''
        end

        lines.pop if lines.last == ''
        lines.join("\n")
      end

      def format_version(version)
        "challenge #{version}"
      end

      private

      def format_client(client, highlight = nil)
        name = highlight ? highlight_match(client['full_name'], highlight) : client['full_name']
        email = client['email']

        "#{name} <#{email}> \e[90m##{client['id']}\e[0m"
      end

      def highlight_match(text, pattern)
        return text unless pattern

        text.gsub(Regexp.new(pattern, Regexp::IGNORECASE)) do |match|
          "\e[1;33m#{match}\e[0m"
        end
      rescue RegexpError
        text
      end

      def format_client_details(client)
        details = []
        rating = client.dig('result', 'rating')
        details << "  Rating: #{rating}" if rating

        feedback_comments = extract_feedback_comments(client)
        details << "  Feedback: #{feedback_comments.map { |c| "\"#{c}\"" }.join(', ')}" if feedback_comments.any?

        details
      end

      def extract_feedback_comments(client)
        Array(client.dig('result', 'feedback')).filter_map do |entry|
          entry.is_a?(Hash) ? entry['comment'] : entry
        end
      end
    end
  end
end
