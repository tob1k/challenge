# frozen_string_literal: true

require 'json'
require 'date'

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

    FEEDBACK_COMMENTS = [
      'Great job on the project!',
      'Needs improvement in communication.',
      'Excellent performance in the last quarter.',
      'Keep up the good work!',
      'Excellent work ethic.',
      'Great team player.',
      'Needs to work on time management.',
      'Very creative.',
      'Could improve on deadlines.',
      'Good attention to detail.',
      'Needs to be more proactive.',
      'Outstanding problem-solving skills.',
      'Shows strong leadership qualities.',
      'Consistently meets expectations.',
      'Requires additional training.'
    ].freeze
    def self.generate(size, filename = nil, **options)
      new.generate(size, filename, **options)
    end

    def generate(size, filename = nil, seed: nil)
      filename ||= "clients_#{size}.json"

      # Set seed for reproducible data if provided
      srand(seed) if seed

      clients = (1..size).map { |id| generate_single_client(id) }

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
        email: "#{username}@#{DOMAINS.sample}",
        result: generate_result
      }
    end

    def generate_result
      {
        rating: (rand(20..50) / 10.0).round(1),
        feedback: generate_feedback
      }
    end

    def generate_feedback
      # Generate 0-3 feedback comments
      num_comments = rand(0..3)
      return [] if num_comments.zero?

      Array.new(num_comments) do
        {
          comment: FEEDBACK_COMMENTS.sample,
          date: random_date
        }
      end
    end

    def random_date
      start_date = Date.new(2023, 1, 1)
      end_date = Date.new(2024, 12, 31)
      random_days = rand((end_date - start_date).to_i)
      (start_date + random_days).to_s
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
