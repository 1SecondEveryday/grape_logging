module GrapeLogging
  module Formatters
    class Logstash
      def call(severity, datetime, _, data)
        {
          '@timestamp': datetime.iso8601,
          '@version': '1',
          severity: severity
        }.merge!(format(data)).to_json + "\n"
      end

      private

      def format(data)
        case data
        when Hash
          data
        when String
          { message: data }
        when Exception
          format_exception(data)
        else
          { message: data.inspect }
        end
      end

      def format_exception(exception)
        {
          exception: {
            message: exception.message
          }
        }
      end
    end
  end
end
