module Reporters
  class LoggerReporter
    def initialize(logger, formatter, log_level)
      @logger = logger || Logger.new($stdout)
      @log_level = log_level || :info
      return unless @logger.respond_to?(:formatter=)

      @logger.formatter = formatter || @logger.formatter || GrapeLogging::Formatters::Default.new
    end

    def perform(params)
      @logger.send(@log_level, params)
    end
  end
end
