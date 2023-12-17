<<<<<<< HEAD
# frozen_string_literal: true

RSpec.describe Loggerx::Loggerxcm0 do
  # Add more tests for other methods here
  describe "init" do
    it "initializes with correct parameters" do
      prefix = "test"
      fname = "test.log"
      log_dir = "/tmp"
      stdout_flag = true
      level = :info
      Loggerx::Loggerxcm0.init(prefix, fname, log_dir, stdout_flag, level)
      expect(Loggerx::Loggerxcm0.valid?).to be_truthy
    end
  end
end
||||||| 2d64699
=======
# frozen_string_literal: true

RSpec.describe Loggerx / Loggerxcm0 do
  # Add more tests for other methods here
  describe "init" do
    it "initializes with correct parameters" do
      prefix = "test"
      fname = "test.log"
      log_dir = "/tmp"
      stdout_flag = true
      level = :info
      Loggerx::Loggerxcm0.init(prefix, fname, log_dir, stdout_flag, level)
      expect(Loggerx::Loggerxcm0).to be_valid
    end
  end
end
>>>>>>> 9f12ef15ea293b95396143db36fa9878b85da1ce
