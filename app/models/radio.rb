class Radio < ApplicationRecord
  validates :title, presence: true
  validates :stream_url, presence: true
end
