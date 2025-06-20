class CreateDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :details do |t|
      t.string :title
      t.string :value
      t.references :section, null: false, foreign_key: true
      t.timestamps
    end
  end
end
