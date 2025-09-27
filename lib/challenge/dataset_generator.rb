# frozen_string_literal: true

require 'json'

module Challenge
  # Generates realistic test datasets for performance testing and development
  class DatasetGenerator
    FIRST_NAMES = %w[
      James Mary John Patricia Robert Jennifer Michael Linda William Elizabeth
      David Barbara Richard Susan Joseph Jessica Thomas Sarah Christopher Karen
      Charles Nancy Daniel Lisa Matthew Betty Mark Helen Donald Donna Paul Carol
      George Ruth Kenneth Shirley Steven Sharon Edward Cynthia
    ].freeze

    LAST_NAMES = %w[
      Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
      Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin
      Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker
      Young Allen King Wright Scott Torres Nguyen Hill Flores Green Adams Nelson Baker
    ].freeze

    DOMAINS = %w[
      example.com test.org sample.net demo.com placeholder.org mockdata.net
      testsite.com sampleemail.org demodata.net examplesite.com
    ].freeze
    def self.generate(size, filename = nil, **options)
      new.generate(size, filename, **options)
    end

    def generate(size, filename = nil, seed: nil)
      filename ||= "clients_#{size}.json"

      # Set seed for reproducible data if provided
      srand(seed) if seed

      puts "Generating #{size} clients..."
      clients = (1..size).map { |id| generate_single_client(id) }

      puts 'Adding duplicates...'
      add_duplicates(clients, size)

      File.write(filename, JSON.pretty_generate(clients))

      filename
    end

    private

    def generate_single_client(id)
      first_name = FIRST_NAMES.sample
      last_name = LAST_NAMES.sample
      username = "#{first_name.downcase}#{last_name.downcase}#{rand(1000)}"

      {
        id: id,
        full_name: "#{first_name} #{last_name}",
        email: "#{username}@#{DOMAINS.sample}"
      }
    end

    def add_duplicates(clients, original_size)
      duplicate_percentage = 0.02 # 2% duplicates
      num_duplicates = [(original_size * duplicate_percentage).to_i, 1].max

      num_duplicates.times do
        target = clients.sample
        source = clients.sample
        target[:email] = source[:email]
      end
    end
  end
end
