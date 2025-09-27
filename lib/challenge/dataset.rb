# frozen_string_literal: true

require 'json'

module Challenge
  # Dataset class for loading and querying client data
  class Dataset
    attr_reader :clients

    def initialize(dataset_path)
      @dataset_path = dataset_path
      validate_dataset_file
      @clients = load_dataset
    end

    def search_names(query)
      return [] if query.nil? || query.strip.empty?

      query_downcase = query.strip.downcase
      clients.select do |client|
        client['full_name'].downcase.include?(query_downcase)
      end
    end

    def duplicate_emails
      email_groups = clients.group_by { |client| client['email'] }
      duplicates = email_groups.select { |_email, clients_with_email| clients_with_email.size > 1 }
      duplicates.values.flatten
    end

    private

    def validate_dataset_file
      return if File.exist?(@dataset_path)

      raise "Dataset file '#{@dataset_path}' does not exist"
    end

    def load_dataset
      JSON.parse(File.read(@dataset_path))
    rescue JSON::ParserError => e
      raise "Invalid JSON in dataset file: #{e.message}"
    rescue StandardError => e
      raise "Error loading dataset: #{e.message}"
    end
  end
end
