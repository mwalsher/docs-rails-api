module ParamHelperMethods
  extend ActiveSupport::Concern

  # E.g. converts "attachments,asdf" to [:attachments], assuming permitted: [:attachments]
  def parse_include_param(permitted:, default: nil)
    include_param = params[:include]
    permitted = permitted.map(&:to_sym)
    includes = include_param.to_s.split(',').map { |param| param.strip.to_sym }
    filtered_includes = includes.select { |key, value| permitted.include?(key) }
    filtered_includes.present? ? filtered_includes : default
  end

  # Basically just a wrapper around ActionController::Parameters#permit for now
  def parse_filter_params(permitted:)
    # Symbolize the keys so the values can be used with keyword arguments in the filter scopes.
    filter_params = params[:filter].try(:permit, permitted).try(:to_h)
  end

  # E.g. converts "email,-sent_at" to {email: :asc, sent_at: :desc}
  def parse_sort_param(permitted:, default: {id: :asc})
    sort_param = params[:sort]
    permitted = permitted.map(&:to_s)
    fields = sort_param.to_s.split(',').map(&:strip)
    ordered_fields = convert_sort_to_ordered_hash(fields)
    filtered_fields = ordered_fields.select { |key, value| permitted.include?(key) }
    (filtered_fields.present? ? filtered_fields : default).try(:symbolize_keys)
  end

  def parse_pagination_param(per_page_default: 50, per_page_max: 1000)
    page_param = params[:page].try(:permit, :number, :size)
    page = page_param.try(:[], :number)
    page = Integer(page) rescue nil if page.present?
    page ||= 1
    per_page = page_param.try(:[], :size)
    per_page = Integer(per_page) rescue nil if per_page.present?
    per_page ||= per_page_default # default
    per_page = per_page_max if per_page > per_page_max # max
    { page: page, per: per_page }
  end

  private

    # E.g. converts ["email","-sent_at"] to {email: :asc, sent_at: :desc}
    def convert_sort_to_ordered_hash(fields)
      fields.each_with_object({}) do |field, hash|
        if field.start_with?('-')
          field = field[1..-1]
          hash[field] = :desc
        else
          hash[field] = :asc
        end
      end
    end
end
