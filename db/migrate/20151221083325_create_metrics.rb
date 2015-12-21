class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :key
      t.string :value
      t.string :group

      t.timestamps null: false
    end
  end
end
