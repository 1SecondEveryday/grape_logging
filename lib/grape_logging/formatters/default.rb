module GrapeLogging
  module Formatters
    class Default
      def call(severity, datetime, _, data)
        "[#{datetime}] #{severity} -- #{format(data)}\n"
      end

      def format(data)
        case data
        when String
          data
        when Exception
          format_exception(data)
        when Hash
          [
            data.delete(:status),
            format_hash(data.delete(:time)),
            "#{data.delete(:method)} #{data.delete(:path)} #{format_hash(data)}"
          ].join(' -- ')
        else
          data.inspect
        end
      end

      private

      def format_hash(hash)
        hash.keys.sort.map { |key| "#{key}=#{hash[key]}" }.join(' ')
      end

      def format_exception(exception)
        backtrace_array = (exception.backtrace || []).map { |line| "\t#{line}" }
        "#{exception.message}\n#{backtrace_array.join("\n")}"
      end
    end
  end
end
