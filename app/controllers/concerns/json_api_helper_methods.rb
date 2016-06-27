module JsonApiHelperMethods
  extend ActiveSupport::Concern

  ##
  # Parses jsonapi-formatted parameters to the standard Rails attribute format.
  # Raises a JsonApiInvalidDataTypeError if an invalid data type is provided.
  #
  # Example:
  #   parse_jsonapi_params!(
  #     type: :email,
  #     permitted: [:from, :to, :subject, :body_text],
  #     relationships: {
  #       attachments: {type: :attachment, permitted: [:content_id] }
  #     }
  #   )
  #
  # Turns:
  #   params: {
  #     data: {
  #       type: :email,
  #       attributes: {
  #         from: "mwalsh@deversus.com",
  #         to: "bobdole@example.com",
  #         subject: "Email with attachments",
  #         body_text: "Hello world"
  #       },
  #       relationships: {
  #         attachments: {
  #           data: [
  #             {type: :attachment, attributes: {content_id: 123}},
  #             {type: :attachment, attributes: {content_id: 456}},
  #           ]
  #         }
  #       }
  #     }
  #   }
  #
  # Into:
  #   {
  #     from: "mwalsh@deversus.com",
  #     to: "bobdole@example.com",
  #     subject: "Email with attachments",
  #     body_text: "Hello world"
  #     attachments_attributes: [
  #       {content_id: 123},
  #       {content_id: 456}
  #     ]
  #   }

  def parse_jsonapi_params!(type:, permitted:, relationships: nil)
    data_params = params.require(:data) rescue nil
    unless data_params.present?
      raise JsonApiBadRequestFormatError.new(
        "data parameter is required at root of request body",
        pointer: :data
      )
    end
    unless data_params[:type].to_s == type.to_s
      raise JsonApiInvalidDataTypeError.new(
        "Bad request",
        details: "Invalid type: '#{data_params[:type]}'. Expected: '#{type}'",
        pointer: [:data, :type]
      )
    end

    permitted = convert_wildcards_to_attribute_keys(permitted, data_params[:attributes])

    permitted_attributes = data_params[:attributes].try(:permit, permitted) || ActionController::Parameters.new

    if relationships.present? && data_params[:relationships].present?
      permitted_attributes = relationships.reduce(permitted_attributes) do |memo, (relationship, options)|
        relationship_params = data_params[:relationships][relationship]
        next unless relationship_params.present?

        relationship_attributes = parse_jsonapi_relationship!(
          relationship: relationship,
          relationship_params: relationship_params,
          type: options[:type],
          permitted: options[:permitted]
        )

        if relationship_attributes.present?
          memo["#{relationship}_attributes".to_sym] = relationship_attributes
        end
        memo
      end
    end
    permitted_attributes
  end

  def verify_jsonapi_content_type
    unless request.headers['Content-Type'] == "application/vnd.api+json"
      raise JsonApiInvalidContentType.new(
        "Unsupported Media Type",
        details: "Content-Type header must be set to 'application/vnd.api+json'",
        status: 415
      )
    end
  end

  private

    # Allows permitting all attributes for a key with the :all wildcard
    # E.g. permitted: [{headers: :all}, :from, :from_name]
    def convert_wildcards_to_attribute_keys(permitted, attributes)
      permitted.map do |p|
        if p.is_a?(Hash) && p.values.first == :all
          key = p.keys.first
          next {key => attributes.try(:[], key).try(:keys) || []}
        end
        p
      end
    end

    def parse_jsonapi_relationship!(relationship:, relationship_params:, type:, permitted:)
      relationship_data = relationship_params[:data]
      if relationship_data.present?
        if relationship_data.is_a?(Array)
          return relationship_data.map do |record_data|
            parse_jsonapi_relationship_data!(
              relationship: relationship,
              relationship_data: record_data,
              type: type,
              permitted: permitted
            )
          end
        else
          return parse_jsonapi_relationship_data!(
            relationship: relationship,
            relationship_data: relationship_data,
            type: type,
            permitted: permitted
          )
        end
      end
    end

    def parse_jsonapi_relationship_data!(relationship:, relationship_data:, type:, permitted:)
      permitted = convert_wildcards_to_attribute_keys(permitted, relationship_data[:attributes])
      relationship_data = relationship_data.permit([:type, {attributes: permitted}])
      unless relationship_data[:type].to_s == type.to_s
        raise JsonApiInvalidDataTypeError.new(
          "Bad request",
          details: "Invalid type: '#{relationship_data[:type]}'. Expected: '#{type}'",
          pointer: [:data, :relationships, relationship, :data, :type]
        )
      end
      return relationship_data[:attributes]
    end
end

class JsonApiRequestError < Exception
  attr_reader :message, :title, :details, :status, :pointer
  def initialize(message, status: nil, details: nil, pointer: nil)
    @message = @title = message
    @details = details
    @status = status
    @pointer = Array.wrap(pointer) if pointer
  end
end
class JsonApiInvalidContentType < JsonApiRequestError; end
class JsonApiBadRequestFormatError < JsonApiRequestError; end
class JsonApiInvalidDataTypeError < JsonApiRequestError; end
