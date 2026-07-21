class LoanDecisionEngine
  MIN_CREDIT_SCORE = 720
  MAX_DEBT_TO_INCOME = 0.35
  MIN_ANNUAL_INCOME = 60_000
  MAX_LOAN_TO_MONTHLY_INCOME_MULTIPLE = 5

  def initialize(loan_application)
    @loan_application = loan_application
    @user = loan_application.user
    @credit_profile = @user.credit_profile
  end

  def call
    reasons = []
    reasons << "No credit profile on file" unless @credit_profile

    if @credit_profile
      reasons << "Credit score #{@credit_profile.credit_score} is below minimum #{MIN_CREDIT_SCORE}" if @credit_profile.credit_score < MIN_CREDIT_SCORE
      reasons << "Debt-to-income #{@credit_profile.debt_to_income} exceeds maximum #{MAX_DEBT_TO_INCOME}" if @credit_profile.debt_to_income > MAX_DEBT_TO_INCOME
    end

    reasons << "Income #{@user.income} is below minimum #{MIN_ANNUAL_INCOME}" if @user.income.nil? || @user.income < MIN_ANNUAL_INCOME

    monthly_income = @user.income.to_f / 12
    max_allowed_amount = monthly_income * MAX_LOAN_TO_MONTHLY_INCOME_MULTIPLE
    reasons << "Requested amount #{@loan_application.amount} exceeds #{MAX_LOAN_TO_MONTHLY_INCOME_MULTIPLE}x monthly income (max #{max_allowed_amount.round(2)})" if @loan_application.amount > max_allowed_amount

    decision = reasons.empty? ? "approved" : (reasons.size == 1 ? "manual_review" : "rejected")
    interest_rate = decision == "approved" ? calculate_interest_rate : nil
    reason_text = reasons.empty? ? "All underwriting criteria met" : reasons.join("; ")

    LoanDecision.create!(
      loan_application: @loan_application,
      decision: decision,
      interest_rate: interest_rate,
      reason: reason_text
    )
  end

  private

  def calculate_interest_rate
    base_rate = 8.0
    base_rate -= 1.0 if @credit_profile.credit_score >= 780
    base_rate += 1.5 if @credit_profile.debt_to_income > 0.25
    base_rate.round(2)
  end
end
