FactoryBot.define do
  factory :exchange_rate do
    created_at { 2.days.ago }
    base_currency { "EUR" }

    ExchangeRate.column_names.select { |x| /[[:upper:]]/.match(x) }.each do |c|
      add_attribute(c.to_sym) { rand(0.5..100) }
    end

    after(:create) do |e|
      e[e.base_currency] = 1.0
      e.save
    end
  end
end
