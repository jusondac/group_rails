class CreateFinanceSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :finance_settings do |t|
      t.references :community, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, default: 0
      t.string :frequency, default: 'monthly' # weekly, monthly, yearly
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
