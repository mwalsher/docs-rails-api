module Constraints
  class ApiVersion
    def initialize(version:, default: false)
      @version = version
      @default = default
    end

    # Allows the API version to be specified via Accept header or `version` param (e.g. via query string)
    def matches?(req)
      req.headers['Accept'].include?("application/vnd.postoffice.v#{@version}") ||
        req.params["version"] == @version.to_s ||
        @default
    end
  end
end
