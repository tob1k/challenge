# frozen_string_literal: true

require 'yaml'

module Challenge
  module Formatters
    # Formats output as YAML with structured data
    class YAMLFormatter
      def format_search_results(results, query)
        {
          'query' => query,
          'count' => results.size,
          'clients' => results
        }.to_yaml
      end

      def format_duplicate_results(duplicates)
        if duplicates.empty?
          { 'duplicates' => [], 'count' => 0 }.to_yaml
        else
          email_groups = duplicates.group_by { |client| client['email'] }
          {
            'duplicates' => email_groups.map do |email, clients|
              { 'email' => email, 'clients' => clients }
            end,
            'count' => duplicates.size
          }.to_yaml
        end
      end

      def format_generation_result(filename, size)
        {
          'status' => 'success',
          'message' => 'Dataset generated successfully',
          'filename' => filename,
          'size' => size
        }.to_yaml
      end

      def format_version(version)
        {
          'application' => 'challenge',
          'version' => version
        }.to_yaml
      end
    end
  end
end
