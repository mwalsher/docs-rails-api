require 'rails_helper'

RSpec.describe Scrapers::Currencylayer, :type => :model do
  describe "#initialize" do
    it "initializes without passing an access_key" do
      expect { Scrapers::Currencylayer.new }.to_not raise_error
    end

    it "sets the access_key if one is provided" do
      scraper = Scrapers::Currencylayer.new("key")
      expect(scraper.access_key).to eq "key"
    end
  end

  describe "#reformat_rates" do
    it "reformats the rates using the expected format" do
      hash = { "success" => true, "quotes" => { "USDCAD" => "1.2953" } }
      expect(Scrapers::Currencylayer.new("key").reformat_rates(hash)).to eq Hash[{ "CAD" => "1.2953" }]
    end
  end

  describe "#read_rates" do
    let(:scraper) do
      scraper = Scrapers::Currencylayer.new("key")
      allow(scraper).to receive(:read_url) do |date|
        Hash[{ date: date}].to_json
      end
      scraper
    end

    it "uses the date string if one is provided" do
      expect(scraper.read_rates("1985-03-29")).to eq Hash[{"date" => "1985-03-29"}]
    end

    it "converts the date to a string if one is provided" do
      expect(scraper.read_rates(Date.parse("2013-08-17"))).to eq Hash[{"date" => "2013-08-17"}]
    end

    it "doesn't use the date if today's date is passed" do
      expect(scraper.read_rates(Date.today)).to eq Hash[{"date" => nil}]
    end
  end

  describe "#parse_result" do
    let(:scraper) { Scrapers::Currencylayer.new("key") }

    it "raises a ParseError if the JSON cannot be parsed" do
      expect { scraper.parse_result("key") }.to raise_error(Scrapers::Currencylayer::ParseError)
    end

    it "raises a UsageLimitExceededError if a 104 error code is present" do
      expect { scraper.parse_result({ error: { code: "104"} }.to_json) }.to raise_error(Scrapers::Currencylayer::UsageLimitExceededError)
    end

    it "raises an ApiError if the error property is present" do
      expect { scraper.parse_result({ error: { code: "123"} }.to_json) }.to raise_error(Scrapers::Currencylayer::ApiError)
    end

    it "returns the parsed json" do
      hash = { "success" => true, "quotes" => { "CAD" => "1.2924" }}
      json = hash.to_json
      expect(scraper.parse_result(json)).to eq hash
    end
  end

  describe "#read_url" do
    let(:scraper) { Scrapers::Currencylayer.new("key") }
    it "raises a ServiceNotAvailableError error if the status returned is not 200" do
      BadResultStub = Class.new do
        def status
          ["404", "Not found"]
        end
      end
      allow(scraper).to receive(:open).and_return(BadResultStub.new)
      expect { scraper.read_url }.to raise_error(Scrapers::Currencylayer::ServiceNotAvailableError)
    end

    it "returns the read result on success status" do
      GoodResultStub = Class.new do
        def status
          ["200", "OK"]
        end

        def read
          "Here it comes"
        end
      end
      allow(scraper).to receive(:open).and_return(GoodResultStub.new)
      expect(scraper.read_url).to eq "Here it comes"
    end
  end

  describe "#source_url" do
    it "raises an error if an access_key is not provided" do
      allow(ENV).to receive(:[]).and_return(nil)
      expect { Scrapers::Currencylayer.new.source_url }.to raise_error(Scrapers::Currencylayer::NoAccessKeyError)
    end

    context "when a date is not provided" do
      subject { Scrapers::Currencylayer.new("key").source_url }
      it "returns the live endpoint" do
        expect(subject).to include("live")
      end
    end

    context "when a date is provided" do
      subject { Scrapers::Currencylayer.new("key").source_url("2016-01-01") }
      it "returns the historical endpoint" do
        expect(subject).to include("historical")
      end

      it "includes the date" do
        expect(subject).to include("2016-01-01")
      end
    end
  end
end
