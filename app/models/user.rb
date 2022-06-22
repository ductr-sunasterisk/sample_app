class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  scope :latest_users, ->{order(created_at: :desc)}
  before_save :downcase_email
  before_create :create_activation_digest

  validates(:name, presence: true, length:
    {maximum: Settings.user.name.max_length})
  validates(:email, presence: true, length: {
              minimum: Settings.user.email.min_length,
              maximum: Settings.user.email.max_length
            },
    format: {with: Settings.user.email.regex_format})
  validates :password, presence: true, length:
    {minimum: Settings.user.password.min_length}, if: :password

  # hash password by bcript algorithm
  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def forget
    update_column :remember_digest, nil
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_token

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
