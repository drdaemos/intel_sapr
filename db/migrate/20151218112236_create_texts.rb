class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :name
      t.string :description
      t.string :path
      t.string :type
      t.boolean :deleted

      t.timestamps null: false
    end
  end
end
