# Language: Ruby, Level: Level 4
class CreateConversations < ActiveRecord::Migration[6.1]
  def change
    create_table :conversations do |t|
      t.integer :author_id
      t.integer :reciever_id

      t.timestamps
    end
    add_index :conversations, :author_id
    add_index :conversations, :reciever_id
    add_index :conversations, [:author_id, :receiver_id], unique: true
  end
end
