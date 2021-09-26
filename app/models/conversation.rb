# Language: Ruby, Level: Level 4
class Conversation < ApplicationRecord
  # Author and Receiver are the same model
  #
  belongs_to :author, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :author, uniqueness: {scope: :receiver}
  has_many :personal_messages, -> { order(created_at: :asc) }, dependent: :destroy

  scope :participating, -> (user) do
    where("(conversations.author_id = ? OR conversation.receiver_id = ?)", user.id, user.id)
  end

  def with(current_user)
    author == current_user ? receiver : author
  end
end
