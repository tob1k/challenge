# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'json'

RSpec.describe Challenge::Dataset do
  let(:sample_clients) do
    [
      { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@gmail.com' },
      { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
      { 'id' => 3, 'full_name' => 'Alex Johnson', 'email' => 'alex.johnson@hotmail.com' },
      { 'id' => 4, 'full_name' => 'Another Jane Smith', 'email' => 'jane.smith@yahoo.com' },
      { 'id' => 5, 'full_name' => 'JOHN DOE', 'email' => 'different.john@example.com' }
    ]
  end

  let(:temp_file) do
    file = Tempfile.new(['test_clients', '.json'])
    file.write(JSON.pretty_generate(sample_clients))
    file.close
    file
  end

  let(:dataset) { described_class.new(temp_file.path) }

  after do
    temp_file&.unlink
  end

  describe '#initialize' do
    context 'when dataset file exists and is valid JSON' do
      it 'loads the clients successfully' do
        expect(dataset.clients).to eq(sample_clients)
      end
    end

    context 'when dataset file does not exist' do
      it 'raises an error' do
        expect do
          described_class.new('/nonexistent/file.json')
        end.to raise_error('Dataset file \'/nonexistent/file.json\' does not exist')
      end
    end

    context 'when dataset file contains invalid JSON' do
      let(:invalid_json_file) do
        file = Tempfile.new(['invalid', '.json'])
        file.write('{ invalid json }')
        file.close
        file
      end

      after do
        invalid_json_file.unlink
      end

      it 'raises an error about invalid JSON' do
        expect do
          described_class.new(invalid_json_file.path)
        end.to raise_error(/Invalid JSON in dataset file/)
      end
    end

    context 'when dataset file is empty' do
      let(:empty_file) do
        file = Tempfile.new(['empty', '.json'])
        file.close
        file
      end

      after do
        empty_file.unlink
      end

      it 'raises an error about invalid JSON' do
        expect do
          described_class.new(empty_file.path)
        end.to raise_error(/Invalid JSON in dataset file/)
      end
    end
  end

  describe '#search_names' do
    context 'with valid query' do
      it 'returns clients with names containing the query (case-insensitive)' do
        results = dataset.search_names('john')
        expect(results).to contain_exactly(
          { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@gmail.com' },
          { 'id' => 3, 'full_name' => 'Alex Johnson', 'email' => 'alex.johnson@hotmail.com' },
          { 'id' => 5, 'full_name' => 'JOHN DOE', 'email' => 'different.john@example.com' }
        )
      end

      it 'returns clients with partial name matches' do
        results = dataset.search_names('Jane')
        expect(results).to contain_exactly(
          { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
          { 'id' => 4, 'full_name' => 'Another Jane Smith', 'email' => 'jane.smith@yahoo.com' }
        )
      end

      it 'returns clients matching last names' do
        results = dataset.search_names('smith')
        expect(results).to contain_exactly(
          { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
          { 'id' => 4, 'full_name' => 'Another Jane Smith', 'email' => 'jane.smith@yahoo.com' }
        )
      end

      it 'returns empty array when no matches found' do
        results = dataset.search_names('NonExistent')
        expect(results).to eq([])
      end
    end

    context 'with edge case queries' do
      it 'returns empty array for nil query' do
        results = dataset.search_names(nil)
        expect(results).to eq([])
      end

      it 'returns empty array for empty string query' do
        results = dataset.search_names('')
        expect(results).to eq([])
      end

      it 'returns empty array for whitespace-only query' do
        results = dataset.search_names('   ')
        expect(results).to eq([])
      end

      it 'handles queries with extra whitespace' do
        results = dataset.search_names('  john  ')
        expect(results.size).to eq(3)
      end
    end
  end

  describe '#duplicate_emails' do
    context 'when duplicates exist' do
      it 'returns all clients with duplicate emails' do
        duplicates = dataset.duplicate_emails
        expect(duplicates).to contain_exactly(
          { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
          { 'id' => 4, 'full_name' => 'Another Jane Smith', 'email' => 'jane.smith@yahoo.com' }
        )
      end
    end

    context 'when no duplicates exist' do
      let(:unique_clients) do
        [
          { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john@example.com' },
          { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' }
        ]
      end

      let(:unique_temp_file) do
        file = Tempfile.new(['unique_clients', '.json'])
        file.write(JSON.pretty_generate(unique_clients))
        file.close
        file
      end

      let(:unique_dataset) { described_class.new(unique_temp_file.path) }

      after do
        unique_temp_file.unlink
      end

      it 'returns empty array' do
        duplicates = unique_dataset.duplicate_emails
        expect(duplicates).to eq([])
      end
    end

    context 'with empty dataset' do
      let(:empty_dataset_file) do
        file = Tempfile.new(['empty_dataset', '.json'])
        file.write('[]')
        file.close
        file
      end

      let(:empty_dataset) { described_class.new(empty_dataset_file.path) }

      after do
        empty_dataset_file.unlink
      end

      it 'returns empty array' do
        duplicates = empty_dataset.duplicate_emails
        expect(duplicates).to eq([])
      end
    end

    context 'with multiple email duplicates' do
      let(:multi_duplicate_clients) do
        [
          { 'id' => 1, 'full_name' => 'User 1', 'email' => 'email1@example.com' },
          { 'id' => 2, 'full_name' => 'User 2', 'email' => 'email1@example.com' },
          { 'id' => 3, 'full_name' => 'User 3', 'email' => 'email2@example.com' },
          { 'id' => 4, 'full_name' => 'User 4', 'email' => 'email2@example.com' },
          { 'id' => 5, 'full_name' => 'User 5', 'email' => 'unique@example.com' }
        ]
      end

      let(:multi_duplicate_file) do
        file = Tempfile.new(['multi_duplicate', '.json'])
        file.write(JSON.pretty_generate(multi_duplicate_clients))
        file.close
        file
      end

      let(:multi_duplicate_dataset) { described_class.new(multi_duplicate_file.path) }

      after do
        multi_duplicate_file.unlink
      end

      it 'returns all clients with any duplicate email' do
        duplicates = multi_duplicate_dataset.duplicate_emails
        expect(duplicates).to contain_exactly(
          { 'id' => 1, 'full_name' => 'User 1', 'email' => 'email1@example.com' },
          { 'id' => 2, 'full_name' => 'User 2', 'email' => 'email1@example.com' },
          { 'id' => 3, 'full_name' => 'User 3', 'email' => 'email2@example.com' },
          { 'id' => 4, 'full_name' => 'User 4', 'email' => 'email2@example.com' }
        )
      end
    end
  end
end
