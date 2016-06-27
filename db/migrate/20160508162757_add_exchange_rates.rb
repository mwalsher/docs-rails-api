class AddExchangeRates < ActiveRecord::Migration[5.0]
  def change
    create_table :exchange_rates do |t|
      t.references :currency
      t.string :exchange_string, null: false
      t.date :date, null: false

      t.timestamps
    end
    add_index :exchange_rates, :date
  end
end
