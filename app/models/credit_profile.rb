class CreditProfile < ApplicationRecord
  belongs_to :user

  validates :credit_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 300, less_than_or_equal_to: 850 }
  validates :debt_to_income, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bankruptcies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end