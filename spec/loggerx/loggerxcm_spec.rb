# frozen_string_literal: true

RSpec.describe Loggerx::Loggerxcm do
  # Add more tests for other methods here
  describe 'init' do
    it 'initializes with correct parameters' do
      prefix = 'test'
      fname = 'test.log'
      log_dir = '/tmp'
      stdout_flag = true
      level = :info
      described_class.init(prefix, fname, log_dir, stdout_flag, level: :info)
      expect(described_class).to be_valid
    end
  end
end
