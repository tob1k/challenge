# frozen_string_literal: true

require 'json'
require 'faker'

module Challenge
  # Generates realistic test datasets for performance testing and development
  class DatasetGenerator
    def self.generate(size, filename = nil, **options)
      new.generate(size, filename, **options)
    end

    def generate(size, filename = nil, seed: nil)
      filename ||= "clients_#{size}.json"

      # Set seed for reproducible data if provided
      Faker::Config.random = Random.new(seed) if seed

      clients = generate_clients(size)
      add_duplicates(clients, size)
      clients.shuffle!

      File.write(filename, JSON.pretty_generate(clients))

      filename
    end

    private

    def generate_clients(size)
      (1..size).map do |id|
        generate_client(id)
      end
    end

    def generate_client(id)
      {
        id: id,
        full_name: Faker::Name.name,
        email: Faker::Internet.email
      }
    end

    def add_duplicates(clients, original_size)
      duplicate_percentage = 0.02 # 2% duplicates
      num_duplicates = [(original_size * duplicate_percentage).to_i, 1].max

      num_duplicates.times do
        original = clients.sample
        duplicate_id = original_size + clients.length + 1
        duplicate_name = Faker::Name.name

        clients << {
          id: duplicate_id,
          full_name: duplicate_name,
          email: original[:email]
        }
      end
    end
  end
end
