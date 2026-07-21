class LoanDecision < ApplicationRecord
  belongs_to :loan_application

  validates :decision, inclusion: { in: %w[approved rejected manual_review] }
  validates :reason, presence: true
end
