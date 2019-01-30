require_relative "spec_helper"
require_relative "../valutist"

RSpec.describe Valutist do
  describe "/latest" do
    subject { get "/latest" }

    context "needs update" do
      before do
        stub_fixer_request_latest
        Timecop.freeze(Time.now)
        subject
      end

      it "returns 200" do
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
          expect(last_record[c].round(4)).to eq(last_response_body[c])
        end
        expect(last_response_body["created_at"]).to eq(Time.now.iso8601)
      end
    end
  end
end
