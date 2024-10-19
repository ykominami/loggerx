# frozen_string_literal: true

RSpec.describe Loggerx do
  let(:logger) { Loggerx::Loggerx.new('prefix', 'fname', 'log_dir', 'stdout_flag', :info) }

  # Add more tests for other methods here
  describe '#initialize' do
    it 'initializes with correct parameters' do
      prefix = 'test'
      fname = 'test.log'
      log_dir = '/tmp'
      stdout_flag = true
      level = :info
      loggerx = Loggerx::Loggerx.new(prefix, fname, log_dir, stdout_flag, level)
      expect(loggerx).to be_a(Loggerx::Loggerx)
    end
  end
end
