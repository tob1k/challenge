# frozen_string_literal: true

require 'json'

module Challenge
  # Dataset class for loading and querying client data
  class Dataset
    attr_reader :clients

    def initialize(dataset_path)
      @clients = load_dataset(dataset_path)
    end

    def search_names(query)
      return [] if query.nil? || query.strip.empty?

      clients.select { |client| client['full_name']&.match?(/#{query.strip}/i) }
    end

    def duplicate_emails
      clients.select { |client| client['email'] && !client['email'].strip.empty? }
             .group_by { |client| client['email'] }
             .select { |_email, clients_with_email| clients_with_email.size > 1 }
             .values.flatten
    end

    def filter_by_rating(rating)
      clients.select do |client|
        client_rating = client.dig('result', 'rating')
        client_rating && client_rating.to_f >= rating.to_f
      end
    end

    private

    def load_dataset(path)
      JSON.parse(File.read(path))
    rescue Errno::ENOENT
      raise "Dataset file '#{path}' does not exist"
    rescue JSON::ParserError => e
      raise "Invalid JSON in dataset file: #{e.message}"
    rescue StandardError => e
      raise "Error loading dataset: #{e.message}"
    end
  end
end
