module SerializerResponders
  extend ActiveSupport::Concern

  def render_with_serializer(options = {})
    # `:serializer` (or `:each_serializer` for collections) is required (for now) as serializer
    # lookup doesn't take into account controller namespaces
    # https://github.com/rails-api/active_model_serializers/issues/1442
    if options[:json].respond_to?(:each)
      options.merge!(each_serializer: resource_serializer)
    else
      options.merge!(serializer: resource_serializer)
    end

    render options
  end

  # Renders errors according to the format specified by the JSON API standard
  # Requires one of +resource+, +resources+, or +title+.
  # Renders an HTTP 406 by default.
  def render_errors_with_serializer(
      resource: nil,
      resources: nil,
      title: nil,
      details: nil,
      pointer: nil,
      status: :unprocessable_entity
    )

    if resource
      render json: resource,
        status: status,
        serializer: ActiveModel::Serializer::ErrorSerializer
    elsif resources
      render json: resources,
        status: status,
        serializer: ActiveModel::Serializer::ErrorsSerializer,
        each_serializer: ActiveModel::Serializer::ErrorSerializer
    elsif title
      render status: status, json: {errors: [{status: status, title: title, details: details, pointer: pointer}.compact]}
    else
      raise ArgumentError.new("resource or resources expected")
    end
  end

  def resource_serializer
    instance_variable_get("@#{resource_name}_serializer") || self.resource_serializer = "#{self.class.parent}::#{resource_class.name}Serializer".constantize
  end

  def resource_serializer=(new_resource_serializer)
    instance_variable_set("@#{resource_name}_serializer", new_resource_serializer)
  end

  # The resource class based on the controller
  # @return [Class]
  def resource_class
    @resource_class ||= resource_name.classify.constantize
  end

  # The singular name for the resource class based on the controller
  # @return [String]
  def resource_name
    @resource_name ||= controller_name.singularize
  end
end
