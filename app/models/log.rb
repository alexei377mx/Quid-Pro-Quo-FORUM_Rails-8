class Log < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  def self.record(user:, action:, description:)
    create(user: user, action: action, description: description)
  end
end
