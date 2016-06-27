class ApplicationController < ActionController::API
  include SerializerResponders
  include ParamHelperMethods
  include JsonApiHelperMethods
  # include ActionController::Cookie

  before_action :verify_jsonapi_content_type

  rescue_from JsonApiRequestError do |exception|
    render_errors_with_serializer(
      title: exception.try(:title) || "Bad request",
      details: exception.try(:details),
      pointer: exception.try(:pointer).try(:join, '/'),
      status: exception.try(:status) || 400
    )
  end

  private

end
