# Call filter scopes directly from your URL params:
#   @products = Product.filter(params.slice(:status, :location, :starts_with))
#   @products = Product.filter(params.slice(:status, {created_at: [:from, :to]))
#
# Example: http://www.justinweiss.com/articles/search-and-filter-rails-models-without-bloating-your-controller/

module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    # Call the class methods with the name "filter_+key+" with their associated
    # values. Most useful for calling named scopes from URL params. Make sure you
    # don't pass stuff directly from the web without whitelisting only the params
    # you care about first!
    def filter(filtering_params)
      results = self.where(nil) # create an anonymous scope
      filtering_params.try(:each) do |key, value|
        if value.present?
          # Symbolize the keys so the values can be used with keyword arguments in the filter scopes.
          value = value.deep_symbolize_keys if value.is_a?(Hash)
          results = results.public_send("filter_#{key}", value)
        end
      end
      results
    end

    # Filters rows between a date range. Both from and to are optional for date range
    # filtering.
    def where_date_range(column:, from: nil, to: nil)
      from = DateTime.parse(from) rescue nil if from.is_a?(String)
      to = DateTime.parse(to) rescue nil if to.is_a?(String)
      scope = where(nil) # create an anonymous scope
      scope = scope.where("#{column} >= ?", from) if from
      scope = scope.where("#{column} <= ?", to) if to
      scope
    end
  end
end
