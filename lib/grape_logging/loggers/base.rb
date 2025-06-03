module GrapeLogging
  module Loggers
    class Base
      def parameters(_request, _status, _response_body)
        {}
      end
    end
  end
end
