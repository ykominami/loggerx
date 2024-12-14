# frozen_string_literal: true

require 'pathname'

module Loggerx
  # The `Loggerx::Loggerxcm0` class is designed to provide logging functionality specific to the Mkspec framework.
  # It encapsulates the logging mechanism, offering a unified interface for recording various levels of messages,
  # such as debug, info, warning, and error. This class aims to facilitate debugging and tracking of the application's
  # flow by providing detailed and structured log messages. It can be configured to log messages to different outputs,
  # including standard output, files, or external logging services, depending on the needs of the framework.
  #
  # @example Logging a debug message
  #   Loggerx::Loggerxcm0.debug("This is a debug message")
  #
  # @example Logging an error message
  #   Loggerx::Loggerxcm0.error("This is an error message")
  #
  # This class may also support log rotation, filtering of log messages based on severity, and formatting of log messages
  # to include timestamps, source identifiers, and other relevant information.
  class Loggerxcm0
    # Implementation omitted
    require 'logger'
    require 'fileutils'
    require 'stringio'

    # LOG_FILENAME_BASE = "#{Time.now.strftime('%Y%m%d-%H%M%S')}.log".freeze
    @log_file = nil
    @log_stdout = nil
    @stdout_backup = $stdout
    @stringio = StringIO.new(+'', 'w+')

    @valid = false

    class << self
      def valid?
        @valid
      end

      def ensure_quantum_log_files(log_dir_pn, limit_of_num_of_files, prefix)
        list = log_dir_pn.children.select { |item| item.basename.to_s.match?("^#{prefix}") }.sort_by(&:mtime)
        latest_index = list.size - limit_of_num_of_files
        list[0, latest_index].map(&:unlink) if latest_index.positive?
      end

      def init(prefix, fname, log_dir, stdout_flag, level = :info)
        return if @log_file

        @error_count = 0
        level_hs = {
          debug: Logger::DEBUG,
          info: Logger::INFO,
          warn: Logger::WARN,
          error: Logger::ERROR,
          fatal: Logger::FATAL,
          unknown: Logger::UNKNOWN
        }
        @log_level = level_hs[level]
        @log_dir_pn = Pathname.new(log_dir)

        @limit_of_num_of_files ||= 5

        ensure_quantum_log_files(@log_dir_pn, @limit_of_num_of_files, prefix)

        @log_stdout = setup_logger_stdout(@log_stdout) if stdout_flag

        fname = nil if fname == false
        fname = prefix + LOG_FILENAME_BASE if fname == :default
        @log_file = setup_logger_file(@log_file, log_dir, fname) if fname

        obj = proc do |_, _, _, msg|
          "#{msg}\n"
        end
        register_log_format(obj)
        register_log_level(@log_level)

        @valid = true

        Loggerxcm.fatal('fatal')
        Loggerxcm.debug('debug')
        Loggerxcm.info('info')
        Loggerxcm.warn('warn')
        Loggerxcm.error('error')
        #        Loggerxcm.unknown("unknown")
      end

      def setup_logger_stdout(log_stdout)
        return log_stdout unless log_stdout.nil?

        begin
          log_stdout = Logger.new($stdout)
        rescue StandardError => exc
          pust exc.message
          @error_count += 1
        end
        log_stdout
      end

      def setup_logger_file(log_file, log_dir, fname)
        filepath = Pathname.new(log_dir).join(fname)
        if log_file.nil?
          begin
            log_file = Logger.new(filepath.to_s)
          rescue Errno::EACCES
            @error_count += 1
          rescue StandardError => exc
            puts exc
            @error_count += 1
          end
        end
        log_file
      end

      def register_log_format(obj)
        @log_file&.formatter = obj
        @log_stdout&.formatter = obj
      end

      def register_log_level(log_level)
        puts "============ #{self}.register_log_level log_level=#{log_level} log_level.class=#{log_level.class} ==========="
        # @log_file&.level = log_level
        # @log_stdout&.level = log_level
        #
        # Log4r互換インターフェイス
        # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
      end

      def to_string(value)
        if value.instance_of?(Array)
          @stdout_backup ||= $stdout
          @stringio ||= StringIO.new(+'', 'w+')
          $stdout = @stringio
          @stringio.rewind
          str = @stringio.read
          @stringio.truncate(0)
          $stdout = @stdout_backup
          str
        else
          value
        end
      end

      def show(value)
        if @valid
          if value.instance_of?(Array)
            value.map do |v|
              str = v.to_s
              Util.puts_valid_str(str)
            end
          else
            Util.puts_valid_str(str)
          end
          str = error_sub(value)
          Util.puts_valid_str(str)
        end
        true
      end

      def error_sub(value)
        str = to_string(value)
        if @valid
          @log_file&.error(str)
          @log_stdout&.error(str)
        end
        str
      end

      def error(value)
        error_sub(value)
        true
      end

      def debug(value)
        str = to_string(value)
        if @valid
          @log_file&.debug(str)
          @log_stdout&.debug(str)
        end

        true
      end

      def info(value)
        str = to_string(value)
        if @valid
          @log_file&.info(str)
          @log_stdout&.info(str)
        end
        true
      end

      def warn(value)
        str = to_string(value)
        if @valid
          @log_file&.warn(str)
          @log_stdout&.warn(str)
        end
        true
      end

      def fatal(value)
        str = to_string(value)
        if @valid
          @log_file&.fatal(str)
          @log_stdout&.fatal(str)
        end
        true
      end

      def close
        retrun unless @valid

        @log_file&.close
        @log_file = nil
        @log_stdout = nil

        @valid = false
        # @log_stdout&.close
      end
    end
  end

  class Loggerxcm < Loggerxcm0
  end
end
