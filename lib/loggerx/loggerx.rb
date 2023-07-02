# frozen_string_literal: true

module Loggerx
  class Loggerx
    require "logger"
    require "fileutils"
    require "stringio"

    LOG_FILENAME_BASE = "#{Time.now.strftime("%Y%m%d-%H%M%S")}.log"
    @log_file = nil
    @log_stdout = nil
    @stdout_backup = $stdout
    @stringio = StringIO.new(+"", "w+")
    #@limit_of_num_of_files ||= 3

    class << self
      def ensure_quantum_log_files(log_dir_pn, limit_of_num_of_files, prefix)
        list = log_dir_pn.children.select { |item| item.basename.to_s.match?("^#{prefix}") }.sort_by(&:mtime)
        latest_index = list.size - limit_of_num_of_files
        list[0, latest_index].map(&:unlink) if latest_index.positive?
      end

      def init_by_hash(hash)
        prefix = hash["prefix"]

        log_dir_pn = Pathname.new( hash["log_dir"] )
        #log_dir_pn = Pathname.new( obj[:log_dir] )
        # log_dir_pn = Pathname.new( obj[0] )

        stdout_flag_str = hash["stdout_flag"]
        case stdout_flag_str
        when "true"
            stdout_flag = true
        else
            stdout_flag = false
        end

        fname_str = hash["fname"]
        case fname_str
        when "default"
            fname = fname_str.to_sym
        when "false"
            fname = false
        else
            fname = fname_str
        end

        level = hash["level"].to_sym

        init(prefix, fname, log_dir_pn, stdout_flag, level)
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
          unknown: Logger::UNKNOWN,
        }
        @log_dir_pn = Pathname.new(log_dir)

        @limit_of_num_of_files ||= 5

        ensure_quantum_log_files(@log_dir_pn, @limit_of_num_of_files, prefix)

        @log_stdout = setup_logger_stdout(@log_stdout) if stdout_flag

        fname = nil if fname == false
        fname = prefix + LOG_FILENAME_BASE if fname == :default
        @log_file = setup_logger_file(log_dir, fname) if fname

        obj = proc do |_, _, _, msg| "#{msg}\n" end
        register_log_format(obj)
        register_log_level(level_hs[level])
      end

      def setup_logger_stdout(log_stdout)
        return log_stdout unless log_stdout.nil?
        begin
          log_stdout = Logger.new($stdout)
        rescue
          @error_count += 1
        end
        log_stdout
      end

      def setup_logger_file(log_dir, fname)
        filepath = Pathname.new(log_dir).join(fname)
        log_file = nil
        begin
          log_file = Logger.new(filepath)
        rescue Errno::EACCES
          @error_count += 1
        rescue
          @error_count += 1
        end
        log_file
      end

      def register_log_format(obj)
        @log_file&.formatter = obj
        @log_stdout&.formatter = obj
      end

      def register_log_level(level)
        @log_file&.level = level
        @log_stdout&.level = level
        #
        # Log4r互換インターフェイス
        # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
      end

      def to_string(value)
        if value.instance_of?(Array)
          @stdout_backup ||= $stdout
          @stringio ||= StringIO.new(+"", "w+")
          $stdout = @stringio
          $stdout = @stdout_backup
          @stringio.rewind
          str = @stringio.read
          @stringio.truncate(0)
          str
        else
          value
        end
      end

      def show(value)
        puts(value)
        str = error_sub(value)
        # puts(str) unless @log_stdout
        puts(str) #unless @log_stdout
        true
      end

      def error_sub(value)
        str = to_string(value)
        @log_file&.error(str)
        @log_stdout&.error(str)
        str
      end

      def error(value)
        error_sub(value)
        true
      end

      def debug(value)
        str = to_string(value)
        # p str
        @log_file&.debug(str)
        @log_stdout&.debug(str)
        true
      end

      def info(value)
        str = to_string(value)
        @log_file&.info(str)
        @log_stdout&.info(str)
        true
      end

      def warn(value)
        str = to_string(value)
        @log_file&.warn(str)
        @log_stdout&.warn(str)
        true
      end

      def fatal(value)
        str = to_string(value)
        @log_file&.fatal(str)
        @log_stdout&.fatal(str)
        true
      end

      def close
        @log_file&.close
        # @log_stdout&.close
      end
    end
  end
end
