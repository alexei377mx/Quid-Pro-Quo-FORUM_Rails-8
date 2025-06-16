class ContactMessage < ApplicationRecord
  validates :name, :email, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :by_reviewed, ->(reviewed) {
    if reviewed.in?([ true, false ])
      where(reviewed: reviewed)
    else
      all
    end
  }
  scope :by_date_range, ->(from, to) {
    if from.present? && to.present?
      where(created_at: from.beginning_of_day..to.end_of_day)
    else
      all
    end
  }
end
