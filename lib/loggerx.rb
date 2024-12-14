# frozen_string_literal: true

require_relative 'loggerx/version'
require_relative 'loggerx/loggerx'
require_relative 'loggerx/loggerxcm'

module Loggerx
  class Error < StandardError; end

  # Your code goes here...
  LOG_FILENAME_BASE = "#{Time.now.strftime('%Y%m%d-%H%M%S')}.log".freeze
end
