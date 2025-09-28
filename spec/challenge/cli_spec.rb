# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require 'json'
require 'tempfile'

RSpec.describe Challenge::CLI do
  let(:cli) { described_class.new }

  let(:temp_file) do
    file = Tempfile.new(['test_clients', '.json'])
    # Use the generator to create realistic test data with known duplicates
    Challenge::DatasetGenerator.generate(20, file.path, seed: 12_345)
    file
  end

  after do
    temp_file&.unlink
  end

  describe '#search' do
    context 'with matching results' do
      it 'finds clients by partial name match' do
        cli.options = { filename: temp_file.path }

        # Search for a common letter that should match multiple clients
        output = capture_stdout { cli.search('a') }

        aggregate_failures do
          expect(output).to match(/Found \d+ client\(s\) matching 'a':/)
          expect(output).to include('<')
          expect(output).to include('@')
        end
      end

      it 'performs case-insensitive search' do
        cli.options = { filename: temp_file.path }

        # Search for common letter in different cases
        output_lower = capture_stdout { cli.search('e') }
        output_upper = capture_stdout { cli.search('E') }

        aggregate_failures do
          expect(output_lower).to match(/Found \d+ client\(s\) matching 'e':/)
          expect(output_upper).to match(/Found \d+ client\(s\) matching 'E':/)
          # Should find the same clients regardless of case
          expect(output_lower.scan(/<.*@.*>/).sort).to eq(output_upper.scan(/<.*@.*>/).sort)
        end
      end
    end

    context 'with no matching results' do
      it 'displays no matches message' do
        cli.options = { filename: temp_file.path }

        expect { cli.search('NonExistent') }.to output(
          "No clients found matching 'NonExistent'\n"
        ).to_stdout
      end
    end

    context 'with file errors' do
      it 'raises Thor::Error for missing file' do
        cli.options = { filename: 'nonexistent.json' }

        expect { cli.search('John') }.to raise_error(Thor::Error, /does not exist/)
      end

      it 'raises Thor::Error for invalid JSON' do
        invalid_file = Tempfile.new(['invalid', '.json'])
        invalid_file.write('invalid json')
        invalid_file.close

        cli.options = { filename: invalid_file.path }

        expect { cli.search('John') }.to raise_error(Thor::Error)

        invalid_file.unlink
      end
    end
  end

  describe '#duplicates' do
    context 'with duplicate emails' do
      it 'finds and displays duplicate emails' do
        cli.options = { filename: temp_file.path }

        output = capture_stdout { cli.duplicates }

        aggregate_failures do
          expect(output).to include('Found duplicate emails:')
          expect(output).to include(':')
          expect(output).to include('<')
          expect(output).to include('@')
          # Should have at least one duplicate due to generator guaranteeing duplicates
          expect(output.scan(/<.*@.*>/).length).to be >= 2
        end
      end
    end

    context 'with no duplicate emails' do
      let(:unique_clients) do
        [
          { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john@example.com' },
          { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' }
        ]
      end

      it 'displays no duplicates message' do
        temp_file = Tempfile.new(['unique_clients', '.json'])
        temp_file.write(JSON.pretty_generate(unique_clients))
        temp_file.close

        cli.options = { filename: temp_file.path }

        expect { cli.duplicates }.to output("No duplicate emails found\n").to_stdout

        temp_file.unlink
      end
    end

    context 'with file errors' do
      it 'raises Thor::Error for missing file' do
        cli.options = { filename: 'nonexistent.json' }

        expect { cli.duplicates }.to raise_error(Thor::Error, /does not exist/)
      end
    end
  end

  describe '#generate' do
    let(:temp_dir) { Dir.mktmpdir }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    context 'with default options' do
      it 'generates dataset with default size' do
        filename = File.join(temp_dir, 'clients_10000.json')
        cli.options = { size: 10_000, filename: filename }

        output = capture_stdout { cli.generate }

        aggregate_failures do
          expect(output).to include("Generated 10000 clients and saved to '#{filename}'")
          expect(File.exist?(filename)).to be true

          generated_data = JSON.parse(File.read(filename))
          expect(generated_data).to be_an(Array)
          expect(generated_data.length).to eq(10_000) # Should be exactly the requested size
        end
      end
    end

    context 'with custom size' do
      it 'generates dataset with specified size' do
        filename = File.join(temp_dir, 'clients_50.json')
        cli.options = { size: 50, filename: filename }

        output = capture_stdout { cli.generate }

        aggregate_failures do
          expect(output).to include("Generated 50 clients and saved to '#{filename}'")
          expect(File.exist?(filename)).to be true

          generated_data = JSON.parse(File.read(filename))
          expect(generated_data).to be_an(Array)
          expect(generated_data.length).to eq(50)
        end
      end
    end

    context 'with existing file' do
      it 'prompts for overwrite confirmation when declined' do
        filename = File.join(temp_dir, 'existing.json')
        File.write(filename, '[]')

        cli.options = { size: 10, filename: filename }

        # Mock the yes? method to return false (decline overwrite)
        allow(cli).to receive(:yes?).and_return(false)

        expect { cli.generate }.to raise_error(Thor::Error, /Generation cancelled by user/)
      end

      it 'overwrites when confirmed' do
        filename = File.join(temp_dir, 'existing.json')
        File.write(filename, '[]')

        cli.options = { size: 10, filename: filename }

        # Mock the yes? method to return true
        allow(cli).to receive(:yes?).and_return(true)

        aggregate_failures do
          expect { cli.generate }.not_to raise_error

          generated_data = JSON.parse(File.read(filename))
          expect(generated_data.length).to eq(10)
        end
      end

      it 'skips confirmation with force option' do
        filename = File.join(temp_dir, 'existing.json')
        File.write(filename, '[]')

        cli.options = { size: 10, filename: filename, force: true }

        aggregate_failures do
          expect { cli.generate }.not_to raise_error

          generated_data = JSON.parse(File.read(filename))
          expect(generated_data.length).to eq(10)
        end
      end
    end

    context 'with invalid size' do
      it 'raises Thor::Error for zero size' do
        cli.options = { size: 0 }

        expect { cli.generate }.to raise_error(Thor::Error, /Size must be a positive integer/)
      end

      it 'raises Thor::Error for negative size' do
        cli.options = { size: -1 }

        expect { cli.generate }.to raise_error(Thor::Error, /Size must be a positive integer/)
      end
    end
  end

  describe '#version' do
    it 'displays the current version' do
      expect { cli.version }.to output("challenge #{Challenge::VERSION}\n").to_stdout
    end
  end

  describe 'command aliases' do
    it 'supports search alias "s"' do
      cli.options = { filename: temp_file.path }

      # Test that the alias works by checking the actual method mapping
      expect(described_class.map['s']).to eq(:search)
    end

    it 'supports duplicate alias "d"' do
      expect(described_class.map['d']).to eq(:duplicates)
    end

    it 'supports generate alias "g"' do
      expect(described_class.map['g']).to eq(:generate)
    end

    it 'supports version aliases' do
      aggregate_failures do
        expect(described_class.map['--version']).to eq(:version)
        expect(described_class.map['-v']).to eq(:version)
      end
    end
  end

  describe 'global options' do
    it 'accepts filename option for all commands' do
      # This is tested implicitly in the command tests above
      # but we can verify the option is defined
      aggregate_failures do
        expect(cli.class.class_options).to have_key(:filename)
        expect(cli.class.class_options[:filename].aliases).to include('-f')
      end
    end
  end

  private

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
