RSpec::Matchers.define :have_jsonapi_response_for do |model|
  match do |response|
    begin
      parsed_response = json_response(response)
      if parsed_response[:data].is_a?(Array)
        parsed_response[:data].reduce(true) do |memo, result|
          memo && result[:type] == model.name.tableize &&
            result[:attributes].is_a?(Hash) &&
            result[:relationships].is_a?(Hash)
        end
      else
        parsed_response.dig(:data, :type) == model.name.tableize &&
          parsed_response.dig(:data, :attributes).is_a?(Hash) &&
          parsed_response.dig(:data, :relationships).is_a?(Hash)
      end
    rescue
      puts red("Response does not conform to json:api format:")
      ap parsed_response || response.body
      false
    end
  end
end

RSpec::Matchers.define :have_jsonapi_data_length_of do |expected_length|
  match do |response|
    parsed_response = json_response(response)
    if data = parsed_response[:data]
      actual_length = Array.wrap(data).length
    else
      actual_length = 0
    end
    if actual_length == expected_length
      true
    else
      puts red("Expected data length to be #{expected_length} but it was actually #{actual_length}")
    end
  end
end

RSpec::Matchers.define :have_jsonapi_data_id do |expected_id|
  match do |response|
    parsed_response = json_response(response)
    expect_attributes(parsed_response.dig(:data), {id: expected_id})
  end
end

RSpec::Matchers.define :have_jsonapi_data_attributes do |expected_attributes|
  match do |response|
    parsed_response = json_response(response)
    expect_attributes(parsed_response.dig(:data, :attributes), expected_attributes)
  end
end

RSpec::Matchers.define :have_jsonapi_data_attributes_at_index do |index, expected_attributes|
  match do |response|
    parsed_response = json_response(response)
    expect_attributes(parsed_response.dig(:data, index, :attributes), expected_attributes)
  end
end

RSpec::Matchers.define :have_jsonapi_relationship_data_length_of do |relationship, expected_length|
  match do |response|
    parsed_response = json_response(response)
    if data = parsed_response.dig(:data, :relationships, relationship, :data)
      actual_length = Array.wrap(data).length
    else
      actual_length = 0
    end
    if actual_length == expected_length
      true
    else
      puts red("Expected #{relationship} data length to be #{expected_length} but it was actually #{actual_length}")
    end
  end
end

RSpec::Matchers.define :have_jsonapi_links do |expected_links|
  match do |response|
    parsed_response = json_response(response)
    expect_attributes(parsed_response[:links], expected_links)
  end
end

RSpec::Matchers.define :have_jsonapi_errors do
  match do |response|
    parsed_response = json_response(response)
    expect(parsed_response[:errors]).to be_present
  end
end

RSpec::Matchers.define :have_jsonapi_error do |expected_error|
  match do |response|
    parsed_response = json_response(response)
    (parsed_response[:errors] || []).detect do |error|
      expect_attributes(error, expected_error)
    end
  end
end

def json_response(response)
  JSON.parse(response.body).with_indifferent_access
end

def expect_attributes(actual_attributes, expected_attributes)
  begin
    expected_attributes.reduce(true) do |memo, (attribute, expected_value)|
      actual_value = actual_attributes[attribute]
      attribute_match = actual_value == expected_value
      unless attribute_match
        puts red("#{attribute} was expected to be '#{expected_value}' but was actually '#{actual_value}'")
      end
      memo && attribute_match
    end
  rescue
    puts red("Response does not contain the expected attributes. Expected:")
    ap expected_attributes
    puts red("Actual:")
    ap actual_attributes
  end
end
