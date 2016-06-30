class RenameDocsAgain < ActiveRecord::Migration[5.0]
  def change
    rename_table :document, :documents
  end
end
