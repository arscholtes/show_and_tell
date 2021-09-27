# Language: Ruby, Level: Level 4
class Fix < ActiveRecord::Migration[6.1]
  def change
    rename_column :conversations, :reciever_id, :receiver_id
  end
end
