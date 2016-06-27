class AddCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :currencies do |t|
      t.string :iso, limit: 3, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :currencies, :iso
    add_index :currencies, :name
  end
end
