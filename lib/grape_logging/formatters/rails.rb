require 'rack/utils'

module GrapeLogging
  module Formatters
    class Rails
      def call(severity, datetime, _, data)
        case data
        when String
          "#{severity[0..0]} [#{datetime}] #{severity} -- : #{data}\n"
        when Exception
          "#{severity[0..0]} [#{datetime}] #{severity} -- : #{format_exception(data)}\n"
        when Hash
          format_hash(data)
        else
          "#{data.inspect}\n"
        end
      end

      private

      def format_exception(exception)
        backtrace_array = (exception.backtrace || []).map { |line| "\t#{line}" }

        [
          "#{exception.message} (#{exception.class})",
          backtrace_array.join("\n")
        ].reject { |line| line == '' }.join("\n")
      end

      def format_hash(hash)
        # Create Rails' single summary line at the end of every request, formatted like:
        # Completed 200 OK in 958ms (Views: 951.1ms | ActiveRecord: 3.8ms)
        # See: actionpack/lib/action_controller/log_subscriber.rb

        message = ''
        additions = []
        status = hash.delete(:status)
        params = hash.delete(:params)

        total_time = hash[:time] && hash[:time][:total]&.round(2)
        view_time  = hash[:time] && hash[:time][:view]&.round(2)
        db_time    = hash[:time] && hash[:time][:db]&.round(2)

        additions << "Views: #{view_time}ms" if view_time
        additions << "DB: #{db_time}ms"      if db_time

        message << "  Parameters: #{params.inspect}\n" if params

        code = ::Rack::Utils::HTTP_STATUS_CODES[status]
        message << "Completed #{status} #{code} in #{total_time}ms"
        message << " (#{additions.join(' | ')})" if additions.size.positive?
        message << "\n"
        message << "\n" if defined?(::Rails.env) && ::Rails.env.development?

        message
      end
    end
  end
end
