require_relative "spec_helper"
require_relative "../valutist"

RSpec.describe Valutist do
  describe "/latest" do
    before do
      stub_fixer_request_latest
    end

    subject { get "/latest" }

    context "no exchange rates in the database" do
      before do
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

  describe "/convert" do
    subject { post("/convert", params, as: :json) }
    let(:params) { {} }

    before do
      stub_fixer_request_latest(
        rates: {
          "CAD": 1.501212,
          "CHF": 1.140761,
          "DKK": 7.466363,
          "EUR": 1,
          "GBP": 0.875217,
          "RON": 4.754729,
          "ISK": 137.203336,
          "JPY": 125.45333,
          "USD": 1.145744
        }
      )
    end

    context "no exchange rates in the database" do
      before do
        Timecop.freeze(Time.now)
        subject
      end

      context "convert from eur to ron" do
        let(:params) { { from: "eur", to: "ron" } }

        it "returns status code 200" do
          expect(last_response.status).to eq(200)
        end

        it "should create an exchange rate entry" do
          expect(ExchangeRate.count).to eq(1)
        end

        it "has correct result in response" do
          expect(last_response_body["result"]).to eq("RON" => 4.7547)
        end

        it "has amount 1 in response" do
          expect(last_response_body["amount"]).to eq(1)
        end

        it "has updated_at in response" do
          expect(last_response_body["updated_at"]).to eq(Time.now.iso8601)
        end
      end

      context "convert from isk to ron and pass amount" do
        let(:params) { { from: "isk", to: "ron", amount: 100 } }

        it "has correct result in response" do
          expect(last_response_body["result"]).to eq("RON" => 3.4655)
        end
      end

      context "convert from isk to ron and pass amount and round" do
        let(:params) { { from: "isk", to: "ron", amount: 100, round: 2 } }

        it "has correct result in response" do
          expect(last_response_body["result"]).to eq("RON" => 3.47)
        end
      end

      context "convert from isk to ron and pass amount" do
        let(:params) { { from: "isk", to: "ron", amount: 100 } }

        it "has correct result in response" do
          expect(last_response_body["result"]).to eq("RON" => 3.4655)
        end
      end

      context "convert from gbp to eur, ron, jpy" do
        let(:params) { { from: "usd", to: %w[eur isk ron jpy] } }

        it "should create an exchange rate entry" do
          expect(ExchangeRate.count).to eq(1)
        end

        it "has correct result in response" do
          expect(last_response_body["result"]).to eq(
            "EUR" => 0.8728,
            "ISK" => 119.7504,
            "JPY" => 109.4951,
            "RON" => 4.1499
          )
        end
      end
    end

    context "there are exchange rates older than 6 hours in the database" do
      before do
        create(:exchange_rate, created_at: 2.days.ago)
        create(:exchange_rate, created_at: 8.hours.ago)
        subject
      end

      let(:params) { { from: "eur", to: "ron" } }

      it "returns status code 200" do
        expect(last_response.status).to eq(200)
      end

      it "should create an exchange rate entry" do
        expect(ExchangeRate.count).to eq(3)
      end
    end

    context "there are exchange rates newer than 6 hours in the database" do
      before do
        create(:exchange_rate, created_at: 8.days.ago)
        create(:exchange_rate, created_at: 3.hours.ago)
        subject
      end

      let(:params) { { from: "eur", to: "ron" } }

      it "returns status code 200" do
        expect(last_response.status).to eq(200)
      end

      it "should not create an exchange rate entry" do
        expect(ExchangeRate.count).to eq(2)
      end
    end
  end
end
