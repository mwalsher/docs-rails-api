Rails.application.config.always_permitted_parameters = [:controller, :action, :format, :version, {page: [:number, :size]}, :sort]
