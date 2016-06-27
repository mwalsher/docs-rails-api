require 'rails_helper'

shared_examples_for "ParamHelperMethods" do
  let(:controller) { described_class.new }
  before { allow(controller).to receive(:params).and_return(params) }

  describe "#parse_include_param" do
    let(:permitted) { [:attachments, :events] }
    let(:default) { [:attachments] }

    context "when include param is not provided" do
      let(:params) { ActionController::Parameters.new() }
      subject { controller.parse_include_param(permitted: permitted, default: default) }

      it "uses the default" do
        expect(subject).to eq default
      end
    end

    context "when an include param is present" do
      context "with a single include" do
        let(:params) { ActionController::Parameters.new(include: "attachments") }
        it "returns the symbolized value" do
          expect(controller.parse_include_param(permitted: permitted, default: default)).to eq [:attachments]
        end
      end

      context "with multiple includes" do
        let(:params) { ActionController::Parameters.new(include: "attachments,events") }
        it "returns the symbolized values" do
          expect(controller.parse_include_param(permitted: permitted, default: default)).to eq [:attachments, :events]
        end
      end

      context "when an include is not permitted" do
        let(:params) { ActionController::Parameters.new(include: "attachments,asdf") }
        it "is ignored" do
          expect(controller.parse_include_param(permitted: permitted, default: default)).to eq [:attachments]
        end
      end
    end
  end

  describe "#parse_filter_params" do
    let(:permitted) { [:name] }

    subject { controller.parse_filter_params(permitted: permitted) }
    context "when filter param is not provided" do
      let(:params) { ActionController::Parameters.new }
      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when filter param is present" do
      context "with nested permitted parameters" do
        let(:permitted) { [{ sent_at: [:from, :to] }] }
        let(:params) { ActionController::Parameters.new(filter: { sent_at: {from: "2016-06-01", to: "2016-06-02"}}) }
        it "returns the nested parameters" do
          expect(subject).to eq Hash["sent_at" => {"from" => "2016-06-01", "to" => "2016-06-02"}]
        end
      end
    end
  end

  describe "#parse_sort_param" do
    let(:permitted) { [:name] }
    let(:default) { Hash[{name: :asc}] }

    context "when sort param is not provided" do
      let(:params) { ActionController::Parameters.new(sort: nil) }
      subject { controller.parse_sort_param(permitted: permitted, default: default) }

      it "uses the default" do
        expect(subject).to eq default
      end
    end

    context "when a sort param is present" do
      context "with single sort field" do
        context "when descending" do
          let(:params) { ActionController::Parameters.new(sort: "-name") }
          it "returns the correct sort value" do
            expect(controller.parse_sort_param(permitted: permitted, default: default)).to eq Hash[{name: :desc}]
          end
        end

        context "when ascending" do
          let(:params) { ActionController::Parameters.new(sort: "name") }
          it "returns the correct sort value" do
            expect(controller.parse_sort_param(permitted: permitted, default: default)).to eq Hash[{name: :asc}]
          end
        end
      end

      context "with multiple sort fields" do
        let(:permitted) { [:name, :date]}
        let(:params) { ActionController::Parameters.new(sort: "name,-date") }
        it "returns the correct sort value" do
          expect(controller.parse_sort_param(permitted: permitted, default: default)).to eq Hash[{name: :asc, date: :desc}]
        end

        context "with spaces" do
          let(:params) { ActionController::Parameters.new(sort: "name, -date") }
          it "returns the correct sort value" do
            expect(controller.parse_sort_param(permitted: permitted, default: default)).to eq Hash[{name: :asc, date: :desc}]
          end
        end
      end

      context "when a sort field is not permitted" do
        let(:params) { ActionController::Parameters.new(sort: "-name,id") }
        it "is ignored" do
          expect(controller.parse_sort_param(permitted: permitted, default: default)).to eq Hash[{name: :desc}]
        end
      end
    end
  end

  describe "#parse_pagination_param" do
    context "empty page param" do
      let(:params) { ActionController::Parameters.new(page: nil) }
      subject { controller.parse_pagination_param }

      it "defaults to the first page" do
        expect(subject[:page]).to eq 1
      end

      it "defaults to per_page_default results per page" do
        expect(subject[:per]).to eq 50
      end
    end

    context "page param present" do
      let(:params) { ActionController::Parameters.new(page: {number: 5, size: 100}) }
      subject { controller.parse_pagination_param }

      it "uses the page number specified" do
        expect(subject[:page]).to eq 5
      end

      it "uses the page size specified" do
        expect(subject[:per]).to eq 100
      end

      context "larger than per_page_max" do
        let(:params) { ActionController::Parameters.new(page: {size: 2000}) }
        it "uses per_page_max" do
          expect(controller.parse_pagination_param).to eq Hash[{page: 1, per: 1000}]
        end
      end

      context "bad params specified" do
        let(:params) { ActionController::Parameters.new(page: {number: "asdf", size: "asdf"}) }
        subject { controller.parse_pagination_param }

        it "uses the defaults" do
          expect(subject).to eq Hash[{page: 1, per: 50}]
        end
      end
    end

    context "when per_page_default is specified" do
      let(:params) { ActionController::Parameters.new(page: nil) }
      subject { controller.parse_pagination_param(per_page_default: 10) }

      it "uses per_page_default" do
        expect(subject).to eq Hash[{page: 1, per: 10}]
      end
    end

    context "when per_page_max is specified" do
      let(:params) { ActionController::Parameters.new(page: {size: 100}) }
      subject { controller.parse_pagination_param(per_page_max: 10) }

      it "allows a page size of per_page_max" do
        expect(subject).to eq Hash[{page: 1, per: 10}]
      end
    end
  end
end

RSpec.describe ApplicationController, type: :controller do
  it_behaves_like "ParamHelperMethods"
end
