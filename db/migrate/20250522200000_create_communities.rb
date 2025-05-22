class CreateCommunities < ActiveRecord::Migration[8.0]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :private, default: false

      t.timestamps
    end
    add_index :communities, :name, unique: true
  end
end
