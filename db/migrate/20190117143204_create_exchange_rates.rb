class CreateExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_rates do |t|
      t.datetime :created_at
      t.string :base_currency
      t.float :BGN
      t.float :BRL
      t.float :BWP
      t.float :CAD
      t.float :CHF
      t.float :DKK
      t.float :EUR
      t.float :GBP
      t.float :HUF
      t.float :INR
      t.float :ISK
      t.float :JPY
      t.float :MXN
      t.float :NOK
      t.float :RUB
      t.float :SAR
      t.float :SEK
      t.float :USD
    end
  end
end
