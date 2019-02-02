require_relative "spec_helper"
require_relative "../valutist"

RSpec.describe Valutist do
  describe "/latest" do
    subject { get "/latest" }

    context "no exchange rates in the database" do
      before do
        stub_fixer_request_latest
        Timecop.freeze(Time.now)
        subject
      end

      it "returns status code 200" do
        expect(last_response.status).to eq(200)
      end

      it "has correct response body" do
        expect(last_response_body.keys)
          .to match_array(
            supported_currencies.append("created_at", "base_currency")
          )
      end

      it "should create an exchange rate entry" do
        expect(ExchangeRate.count).to eq(1)
      end

      it "response corresponds to last exchange rate record" do
        last_record = ExchangeRate.last
        supported_currencies.each do |c|
          expect(last_record[c]).to eq(last_response_body[c])
        end
        expect(last_response_body["created_at"]).to eq(Time.now.iso8601)
      end
    end

    context "there are exchange rates older than 6 hours in the database" do
      before do
        create(:exchange_rate, created_at: 2.days.ago)
        create(:exchange_rate, created_at: 8.hours.ago)

        stub_fixer_request_latest
        subject
      end

      it "should create an exchange rate entry" do
        expect(ExchangeRate.count).to eq(3)
      end

      it "returns status code 200" do
        expect(last_response.status).to eq(200)
      end

      it "response corresponds to last exchange rate record" do
        last_record = ExchangeRate.last
        supported_currencies.each do |c|
          expect(last_record[c]).to eq(last_response_body[c])
        end
      end
    end

    context "there are exchange rates newer than 6 hours in the database" do
      before do
        create(:exchange_rate, created_at: 8.days.ago)
        create(:exchange_rate, created_at: 2.hours.ago)

        stub_fixer_request_latest
        subject
      end

      it "should not create an exchange rate entry" do
        expect(ExchangeRate.count).to eq(2)
      end

      it "returns status code 200" do
        expect(last_response.status).to eq(200)
      end

      it "response corresponds to last exchange rate record" do
        last_record = ExchangeRate.last
        supported_currencies.each do |c|
          expect(last_record[c]).to eq(last_response_body[c])
        end
      end
    end
  end
end
