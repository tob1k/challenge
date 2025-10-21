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

  describe '#filter_by_rating' do
    let(:rated_clients) do
      [
        { 'id' => 1, 'full_name' => 'High Rated', 'email' => 'high@example.com',
          'result' => { 'rating' => 4.5, 'feedback' => [] } },
        { 'id' => 2, 'full_name' => 'Medium Rated', 'email' => 'medium@example.com',
          'result' => { 'rating' => 3.2, 'feedback' => [] } },
        { 'id' => 3, 'full_name' => 'Low Rated', 'email' => 'low@example.com',
          'result' => { 'rating' => 2.0, 'feedback' => [] } },
        { 'id' => 4, 'full_name' => 'No Result', 'email' => 'noresult@example.com' },
        { 'id' => 5, 'full_name' => 'Result No Rating', 'email' => 'norating@example.com',
          'result' => { 'feedback' => [] } },
        { 'id' => 6, 'full_name' => 'Nil Rating', 'email' => 'nilrating@example.com',
          'result' => { 'rating' => nil, 'feedback' => [] } },
        { 'id' => 7, 'full_name' => 'Perfect Score', 'email' => 'perfect@example.com',
          'result' => { 'rating' => 5.0, 'feedback' => [] } }
      ]
    end

    let(:rated_temp_file) do
      file = Tempfile.new(['rated_clients', '.json'])
      file.write(JSON.pretty_generate(rated_clients))
      file.close
      file
    end

    let(:rated_dataset) { described_class.new(rated_temp_file.path) }

    after do
      rated_temp_file.unlink
    end

    context 'with valid ratings' do
      it 'returns clients with rating >= threshold' do
        results = rated_dataset.filter_by_rating(3.0)
        expect(results).to contain_exactly(
          { 'id' => 1, 'full_name' => 'High Rated', 'email' => 'high@example.com',
            'result' => { 'rating' => 4.5, 'feedback' => [] } },
          { 'id' => 2, 'full_name' => 'Medium Rated', 'email' => 'medium@example.com',
            'result' => { 'rating' => 3.2, 'feedback' => [] } },
          { 'id' => 7, 'full_name' => 'Perfect Score', 'email' => 'perfect@example.com',
            'result' => { 'rating' => 5.0, 'feedback' => [] } }
        )
      end

      it 'returns clients with exact rating match' do
        results = rated_dataset.filter_by_rating(4.5)
        expect(results).to contain_exactly(
          { 'id' => 1, 'full_name' => 'High Rated', 'email' => 'high@example.com',
            'result' => { 'rating' => 4.5, 'feedback' => [] } },
          { 'id' => 7, 'full_name' => 'Perfect Score', 'email' => 'perfect@example.com',
            'result' => { 'rating' => 5.0, 'feedback' => [] } }
        )
      end

      it 'returns all clients when threshold is very low' do
        results = rated_dataset.filter_by_rating(0.0)
        expect(results.size).to eq(4) # Only clients with actual ratings
      end

      it 'returns empty array when threshold is very high' do
        results = rated_dataset.filter_by_rating(10.0)
        expect(results).to eq([])
      end
    end

    context 'with missing or invalid rating data' do
      it 'excludes clients with no result field' do
        results = rated_dataset.filter_by_rating(0.0)
        emails = results.map { |c| c['email'] }
        expect(emails).not_to include('noresult@example.com')
      end

      it 'excludes clients with result but no rating field' do
        results = rated_dataset.filter_by_rating(0.0)
        emails = results.map { |c| c['email'] }
        expect(emails).not_to include('norating@example.com')
      end

      it 'excludes clients with nil rating' do
        results = rated_dataset.filter_by_rating(0.0)
        emails = results.map { |c| c['email'] }
        expect(emails).not_to include('nilrating@example.com')
      end
    end

    context 'with string rating input' do
      it 'handles string input for threshold' do
        results = rated_dataset.filter_by_rating('3.5')
        expect(results).to contain_exactly(
          { 'id' => 1, 'full_name' => 'High Rated', 'email' => 'high@example.com',
            'result' => { 'rating' => 4.5, 'feedback' => [] } },
          { 'id' => 7, 'full_name' => 'Perfect Score', 'email' => 'perfect@example.com',
            'result' => { 'rating' => 5.0, 'feedback' => [] } }
        )
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
        results = empty_dataset.filter_by_rating(3.0)
        expect(results).to eq([])
      end
    end
  end

  describe 'handling malformed data' do
    let(:malformed_clients) do
      [
        { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john@example.com' },
        { 'id' => 2, 'full_name' => 'Jane Smith' }, # Missing email
        { 'id' => 3, 'email' => 'bob@example.com' }, # Missing full_name
        { 'id' => 4, 'full_name' => '', 'email' => 'empty@example.com' }, # Empty full_name
        { 'id' => 5, 'full_name' => 'Alice Wilson', 'email' => '' }, # Empty email
        { 'id' => 6, 'full_name' => nil, 'email' => 'null@example.com' }, # Nil full_name
        { 'id' => 7, 'full_name' => 'Bob Brown', 'email' => nil }, # Nil email
        { 'id' => 8, 'full_name' => 'Charlie Davis', 'email' => 'charlie@example.com' },
        { 'id' => 9, 'full_name' => 'David Evans', 'email' => 'charlie@example.com' } # Duplicate
      ]
    end

    let(:malformed_file) do
      file = Tempfile.new(['malformed_data', '.json'])
      file.write(JSON.pretty_generate(malformed_clients))
      file.close
      file
    end

    let(:malformed_dataset) { described_class.new(malformed_file.path) }

    after do
      malformed_file.unlink
    end

    describe '#search_names' do
      it 'only searches clients with valid full_name fields' do
        results = malformed_dataset.search_names('John')
        expect(results).to contain_exactly(
          { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john@example.com' }
        )
      end

      it 'ignores clients with missing full_name' do
        # Client id: 3 has email 'bob@example.com' but no full_name field
        # Should not be found when searching for 'bob' since we only search full_name
        results = malformed_dataset.search_names('bob')
        # Should find Bob Brown (id: 7) who has valid full_name but not client id: 3
        expect(results).to contain_exactly(
          { 'id' => 7, 'full_name' => 'Bob Brown', 'email' => nil }
        )
      end

      it 'ignores clients with nil full_name' do
        results = malformed_dataset.search_names('null')
        expect(results).to eq([])
      end

      it 'ignores clients with empty full_name' do
        results = malformed_dataset.search_names('empty')
        expect(results).to eq([])
      end

      it 'finds clients with valid names regardless of email issues' do
        results = malformed_dataset.search_names('Alice')
        expect(results).to contain_exactly(
          { 'id' => 5, 'full_name' => 'Alice Wilson', 'email' => '' }
        )
      end
    end

    describe '#duplicate_emails' do
      it 'only considers clients with valid email addresses' do
        duplicates = malformed_dataset.duplicate_emails
        expect(duplicates).to contain_exactly(
          { 'id' => 8, 'full_name' => 'Charlie Davis', 'email' => 'charlie@example.com' },
          { 'id' => 9, 'full_name' => 'David Evans', 'email' => 'charlie@example.com' }
        )
      end

      it 'ignores clients with missing emails' do
        # Jane Smith has no email field - should be ignored
        emails = malformed_dataset.duplicate_emails.map { |client| client['email'] }
        expect(emails).not_to include(nil)
      end

      it 'ignores clients with empty emails' do
        # Alice Wilson has empty email - should be ignored
        emails = malformed_dataset.duplicate_emails.map { |client| client['email'] }
        expect(emails).not_to include('')
      end

      it 'ignores clients with nil emails' do
        # Bob Brown has nil email - should be ignored
        emails = malformed_dataset.duplicate_emails.map { |client| client['email'] }
        expect(emails.compact).to eq(emails) # No nil values
      end
    end
  end
end
