module Base64Helper
  def base64_encode(file)
    encoded_content = Base64.urlsafe_encode64(file.read) and file.close
    content_type = MIME::Types.type_for(file.path).first.content_type
    "data:#{content_type};base64,#{encoded_content}"
  end
end
