class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  REASONS = {
    1 => :offensive_content,
    2 => :spam,
    3 => :false_information,
    4 => :harassment,
    5 => :inappropriate_language,
    6 => :other
  }.freeze

  validates :reason, presence: true, inclusion: {
    in: REASONS.keys.map(&:to_s),
    message: :invalid_reason
  }

  def reason_text
    I18n.t("reports.reasons.#{REASONS[reason.to_i]}")
  end

  scope :without_deleted_content, lambda {
    joins(<<~SQL)
      LEFT JOIN posts ON posts.id = reports.reportable_id AND reports.reportable_type = 'Post'
      LEFT JOIN comments ON comments.id = reports.reportable_id AND reports.reportable_type = 'Comment'
      LEFT JOIN posts AS comment_posts ON comment_posts.id = comments.post_id
    SQL
    .where(<<~SQL, false, false)
      (reports.reportable_type != 'Post' OR posts.deleted_by_admin = ?) AND
      (reports.reportable_type != 'Comment' OR comment_posts.deleted_by_admin = ?)
    SQL
  }

  scope :by_type, ->(type) { where(reportable_type: type) if type.present? }
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
