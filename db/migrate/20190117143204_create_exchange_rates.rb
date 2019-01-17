class CreateExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_rates do |t|
      t.datetime :created_at
      t.string :eur
      t.string :usd
      t.string :gbp
      t.string :sek
      t.string :cad
      t.string :jpy
      t.string :rub
      t.string :inr
      t.string :nok
      t.string :bgn
      t.string :dkk
      t.string :sar
      t.string :huf
      t.string :bwp
      t.string :mxn
      t.string :isk
      t.string :brl
    end
  end
end
