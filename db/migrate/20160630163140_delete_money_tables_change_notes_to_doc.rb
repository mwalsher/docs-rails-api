class DeleteMoneyTablesChangeNotesToDoc < ActiveRecord::Migration[5.0]
  def change
    drop_table :currencies
    drop_table :exchange_rates
    rename_table :notes, :documents
  end
end
