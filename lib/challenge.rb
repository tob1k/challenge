# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require_relative 'challenge/formatters/tty_formatter'
require_relative 'challenge/formatters/csv_formatter'
require_relative 'challenge/formatters/json_formatter'
require_relative 'challenge/formatters/xml_formatter'

require_relative 'challenge/version'
require_relative 'challenge/dataset'
require_relative 'challenge/dataset_generator'
require_relative 'challenge/cli'
