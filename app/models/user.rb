class User < ApplicationRecord
    has_many :loan_applications, dependent: :destroy
    has_one :credit_profile, dependent: :destroy
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employment_status, presence: true, inclusion: { in: %w[employed self_employed unemployed retired] }
  validates :income, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end