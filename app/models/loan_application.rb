class LoanApplication < ApplicationRecord
  belongs_to :user
  has_one :loan_decision, dependent: :destroy
  validates :amount, numericality: { greater_than: 0 }
  validates :purpose, presence: true
  validates :term_months, numericality: { greater_than: 0, only_integer: true }
  validates :status, inclusion: { in: %w[pending approved rejected manual_review] }
end