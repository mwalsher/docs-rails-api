require 'rails_helper'

shared_examples_for "JsonApiHelperMethods" do
  let(:controller) { described_class.new }

  describe "#parse_jsonapi_params!" do
    let(:relationships) { nil }
    before { allow(controller).to receive(:params).and_return(params) }

    subject do
      controller.send :parse_jsonapi_params!,
        type: :email,
        permitted: [:from, :to, :subject, :body_text],
        relationships: relationships
    end

    context "with empty parameters" do
      let(:params) { ActionController::Parameters.new }
      it "raises a JsonApiBadRequestFormatError" do
        expect { subject }.to raise_error(JsonApiBadRequestFormatError)
      end
    end

    context "with invalid type" do
      let(:params) { ActionController::Parameters.new(data: {type: :badtype}) }

      it "raises a JsonApiInvalidDataTypeError" do
        expect { subject }.to raise_error(JsonApiInvalidDataTypeError)
      end
    end

    context "with unpermitted parameters" do
      let(:params) do
        ActionController::Parameters.new(
          data: {
            type: :email,
            attributes: {
              from: "mwalsh@deversus.com",
              badparam: "asdf"
            }
          }
        )
      end

      it do
        is_expected.to eq ActionController::Parameters.new(
          from: "mwalsh@deversus.com"
        ).permit!
      end
    end

    context "with valid parameters" do
      let(:params) do
        ActionController::Parameters.new(
          data: {
            type: :email,
            attributes: {
              from: "mwalsh@deversus.com",
              to: "bobdole@example.com",
              subject: "Email with attachments",
              body_text: "Hello world"
            }
          }
        )
      end

      it do
        is_expected.to eq ActionController::Parameters.new(
          from: "mwalsh@deversus.com",
          to: "bobdole@example.com",
          subject: "Email with attachments",
          body_text: "Hello world"
        ).permit!
      end
    end

    context "with relationship parameters" do
      let(:relationships) { Hash[attachments: {type: :attachment, permitted: [:content_id]}] }
      let(:params) do
        ActionController::Parameters.new(
          data: {
            type: :email,
            attributes: {from: "mwalsh@deversus.com"},
            relationships: {
              attachments: {
                data: [
                  {type: :attachment, attributes: {content_id: 123}},
                  {type: :attachment, attributes: {content_id: 456}},
                ]
              }
            }
          }
        )
      end

      it do
        is_expected.to eq ActionController::Parameters.new(
          from: "mwalsh@deversus.com",
          attachments_attributes: [
            {content_id: 123},
            {content_id: 456},
          ]
        ).permit!
      end
    end
  end

  describe "#convert_wildcards_to_attributes" do
    let(:permitted) { [{headers: :all}, :from] }
    subject { controller.send(:convert_wildcards_to_attribute_keys, permitted, attributes) }

    context "when the wildcard attribute is present in the params" do
      let(:attributes) { Hash[{headers: {hello: "world", hi: "there"}, from: "asdf"}] }
      it "converts :all to the attribute keys for the permitted parameter" do
        expect(subject).to eq [{headers: [:hello, :hi]}, :from]
      end
    end

    context "when the wildcard attribute is not present in the params" do
      let(:attributes) { Hash[{headers: {}, from: "asdf"}] }

      it "converts :all to an empty array for the permitted parameter" do
        expect(subject).to eq [{headers: []}, :from]
      end
    end

    context "when attributes is nil" do
      let(:attributes) { nil }

      it "converts :all to an empty array for the permitted parameter" do
        expect(subject).to eq [{headers: []}, :from]
      end
    end
  end

  describe "#parse_jsonapi_relationship!" do
    subject do
      controller.send :parse_jsonapi_relationship!,
        relationship: :attachments,
        relationship_params: relationship_params,
        type: :attachment,
        permitted: [:content_id]
    end

    context "with an empty record" do
      let(:relationship_params) do
        ActionController::Parameters.new(
          data: {}
        )
      end

      it { is_expected.to eq nil }
    end

    context "with unpermitted parameters" do
      let(:relationship_params) do
        ActionController::Parameters.new(
          data: {
            type: :attachment,
            attributes: { content_id: 123, ignored_parameter: 456 }
          }
        )
      end

      it { is_expected.to eq ActionController::Parameters.new(content_id: 123).permit! }
    end

    context "with a single record" do
      let(:relationship_params) do
        ActionController::Parameters.new(
          data: {
            type: :attachment,
            attributes: { content_id: 123 }
          }
        )
      end

      it { is_expected.to eq ActionController::Parameters.new(content_id: 123).permit! }
    end

    context "with multiple records" do
      let(:relationship_params) do
        ActionController::Parameters.new(
          data: [{
            type: :attachment,
            attributes: { content_id: 123 }
          },
          {
            type: :attachment,
            attributes: { content_id: 456 }
          }]
        )
      end
      it do
        is_expected.to eq [
          ActionController::Parameters.new(content_id: 123).permit!,
          ActionController::Parameters.new(content_id: 456).permit!
        ]
      end
    end
  end

  describe "#parse_jsonapi_relationship_data!" do
    let(:relationship_data) do
      ActionController::Parameters.new(
        type: :attachment,
        attributes: { content_id: 123 }
      ).permit!
    end
    let(:type) { :attachment }

    subject do
      controller.send :parse_jsonapi_relationship_data!,
        relationship: :attachments,
        relationship_data: relationship_data,
        type: type,
        permitted: [:content_id]
    end

    context "invalid data type" do
      let(:type) { :badtype }
      it "raises a JsonApiInvalidDataTypeError" do
        expect { subject }.to raise_error(JsonApiInvalidDataTypeError)
      end
    end

    context "valid data type" do
      it { is_expected.to eq ActionController::Parameters.new(content_id: 123).permit! }
    end
  end
end

RSpec.describe ApplicationController, type: :controller do
  it_behaves_like "JsonApiHelperMethods"
end
