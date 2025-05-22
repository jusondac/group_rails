class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.string :role, default: 'member'
      t.string :status, default: 'pending' # pending, approved, rejected

      t.timestamps
    end
    add_index :memberships, [ :user_id, :community_id ], unique: true
  end
end
