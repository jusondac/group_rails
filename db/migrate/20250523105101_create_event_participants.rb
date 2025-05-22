class CreateEventParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :event_participants do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'attending' # attending, maybe, declined

      t.timestamps
    end
    add_index :event_participants, [ :user_id, :event_id ], unique: true
  end
end
