class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :membership, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :paid_at
      t.datetime :due_date, null: false
      t.string :status, default: 'pending' # pending, paid, overdue
      t.string :period # e.g., "May 2025", "Week 21, 2025"

      t.timestamps
    end
  end
end
