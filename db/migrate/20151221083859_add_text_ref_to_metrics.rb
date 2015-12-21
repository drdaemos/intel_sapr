class AddTextRefToMetrics < ActiveRecord::Migration
  def change
    add_reference :metrics, :text, index: true, foreign_key: true
  end
end
