class Micropost < ApplicationRecord
  belongs_to :user
  scope :newest, -> {order(created_at: :desc)}
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: Settings.microposts.content.max_length }
end
