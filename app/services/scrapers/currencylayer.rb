module Scrapers
  class Currencylayer
    CL_LIVE_URL = 'http://apilayer.net/api/live'.freeze
    CL_HISTORICAL_URL = 'http://apilayer.net/api/historical'.freeze
    CL_SOURCE = 'USD'.freeze
    attr_accessor :access_key
    attr_reader :rates

    class UsageLimitExceededError < StandardError; end
    class NoAccessKeyError < StandardError; end
    class ServiceNotAvailableError < StandardError; end
    class ApiError < StandardError; end
    class ParseError < StandardError; end

    def initialize(access_key = nil)
      @access_key = access_key || ENV['CURRENCY_LAYER_API_KEY']
    end

    # @return [Hash] Exchange rates from USD formatted as, e.g. { "CAD" => 1.28924 }
    def get_rates(date = nil)
      reformat_rates(read_rates(date))
    end

    # Reformats the raw exchange rates to a hash with the expected formatted
    def reformat_rates(rates)
      rates['quotes'].reduce({}) do |memo, (k, v)|
        memo[k.gsub(/^USD/i, '')] = v
        memo
      end
    end

    # Get raw exchange rates from url
    # @return [String] JSON content
    def read_rates(date = nil)
      if date
        date = date.is_a?(String) ? date : date.strftime('%F')
        date = nil if Date.parse(date) == Date.today
      end
      @rates = parse_result(read_url(date))
      @rates
    end

    # Resume test this
    def parse_result(result)
      parsed_result = JSON.parse(result)
      if !parsed_result['success'] && error = parsed_result['error']
        raise UsageLimitExceededError.new if error['code'] == "104"
        raise ApiError.new("Query failed with code #{error['code']}: #{error['info']}")
      end
      parsed_result
    rescue JSON::ParserError
      raise ParseError.new("Unable to parse #{result}")
    end

    # Opens an url and reads the content
    # @return [String] unparsed JSON content
    def read_url(date_str = nil)
      result = open(source_url(date_str), allow_redirections: :all) # rescue nil
      status_code, status_message = result.try(:status)
      raise ServiceNotAvailableError.new(result.status.join) unless status_code == "200"
      result.read
    end

    # Source url of CurrencylayerBank
    # defined with access_key
    # @return [String] the remote API url
    def source_url(date_str = nil)
      raise NoAccessKeyError.new if access_key.nil? || access_key.empty?
      cl_url = date_str ? CL_HISTORICAL_URL : CL_LIVE_URL
      url = "#{cl_url}?source=#{CL_SOURCE}&access_key=#{access_key}"
      url += "&date=#{date_str}" if date_str
      url
    end
  end
end
