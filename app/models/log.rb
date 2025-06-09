class Log < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  def self.record(user:, action:, description:)
    create(user: user, action: action, description: description)
  end

  def self.delete_old_logs
    where("created_at < ?", 1.month.ago).delete_all
  end
end
