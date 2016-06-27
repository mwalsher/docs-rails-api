require 'rails_helper'

shared_examples_for "Filterable" do
  describe "#filter" do
    subject { described_class.filter(filter_params) }

    context "when filtering_params is empty" do
      let(:filter_params) { nil }

      it "returns a scope" do
        expect(subject).to be_a ActiveRecord::Relation
      end
    end
  end

  describe "#where_date_range" do
    let(:from) { nil }
    let(:to) { nil }
    subject { described_class.where_date_range(column: date_column, from: from, to: to) }

    context "when from and to are nil" do
      it "returns a scope" do
        expect(subject).to be_a ActiveRecord::Relation
      end
    end

    context "when only from is present" do
      let(:from) { "2016-06-22" }

      it "filters by from only" do
        expect(subject.to_sql).to include("#{date_column} >= '2016-06-22")
        expect(subject.to_sql).to_not include("#{date_column} <=")
      end
    end

    context "when both from and to are present" do
      let(:from) { "2016-06-22" }
      let(:to) { "2016-06-25" }

      it "filters by both" do
        expect(subject.to_sql).to include("#{date_column} >= '2016-06-22")
        expect(subject.to_sql).to include("#{date_column} <= '2016-06-25")
      end
    end

    context "when an invalid date string is provided" do
      let(:from) { "2016-06-22" }
      let(:to) { "asdf" }

      it "ignores it" do
        expect(subject.to_sql).to include("#{date_column} >= '2016-06-22")
        expect(subject.to_sql).to_not include("#{date_column} <=")
      end
    end
  end
end

RSpec.describe Email, type: :model do
  it_behaves_like "Filterable" do
    let(:date_column) { :sent_at }
  end
end
