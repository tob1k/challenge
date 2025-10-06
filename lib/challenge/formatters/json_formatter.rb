# frozen_string_literal: true

require 'json'

module Challenge
  module Formatters
    # Formats output as structured JSON with metadata
    class JSONFormatter
      def format_search_results(results, query)
        {
          query: query,
          count: results.size,
          clients: results
        }.to_json
      end

      def format_duplicate_results(duplicates)
        if duplicates.empty?
          { duplicates: [], count: 0 }.to_json
        else
          email_groups = duplicates.group_by { |client| client['email'] }
          {
            duplicates: email_groups.map do |email, clients|
              { email: email, clients: clients }
            end,
            count: duplicates.size
          }.to_json
        end
      end

      def format_generation_result(filename, size)
        {
          status: 'success',
          message: 'Dataset generated successfully',
          filename: filename,
          size: size
        }.to_json
      end

      def format_filtered_results(results)
        {
          count: results.size,
          clients: results.map { |client| serialize_filtered_client(client) }
        }.to_json
      end

      def format_version(version)
        {
          application: 'challenge',
          version: version
        }.to_json
      end

      private

      def serialize_filtered_client(client)
        {
          id: client['id'],
          full_name: client['full_name'],
          email: client['email'],
          result: {
            rating: client.dig('result', 'rating'),
            feedback: Array(client.dig('result', 'feedback')).map do |entry|
              entry.is_a?(Hash) ? entry['comment'] : entry
            end.compact
          }
        }
      end
    end
  end
end
