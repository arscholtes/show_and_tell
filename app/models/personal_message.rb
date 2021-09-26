# Language: Ruby, Level: Level 4
class PersonalMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true
end
