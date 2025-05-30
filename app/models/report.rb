class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  REASONS = [
    "Contenido ofensivo",
    "Spam o publicidad no solicitada",
    "Información falsa o engañosa",
    "Acoso o abuso",
    "Lenguaje inapropiado",
    "Otro"
  ].freeze

  validates :reason, presence: true, inclusion: { in: REASONS, message: "no es una razón válida" }
end
