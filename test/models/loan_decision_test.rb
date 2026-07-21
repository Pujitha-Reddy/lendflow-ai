require "test_helper"

class LoanDecisionEngineTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      first_name: "Test", last_name: "User", email: "test#{rand(10000)}@example.com",
      income: 90_000, employment_status: "employed"
    )
    @user.create_credit_profile!(credit_score: 750, debt_to_income: 0.20, bankruptcies: 0)
  end

  test "approves an application that meets all criteria" do
    loan = @user.loan_applications.create!(amount: 10_000, purpose: "debt_consolidation", term_months: 36)
    decision = LoanDecisionEngine.new(loan).call
    assert_equal "approved", decision.decision
    assert decision.interest_rate.present?
  end

  test "rejects an application with multiple failures" do
    @user.credit_profile.update!(credit_score: 600, debt_to_income: 0.50)
    loan = @user.loan_applications.create!(amount: 10_000, purpose: "debt_consolidation", term_months: 36)
    decision = LoanDecisionEngine.new(loan).call
    assert_equal "rejected", decision.decision
  end

  test "sends borderline applications to manual review" do
    @user.credit_profile.update!(credit_score: 700) # only credit score fails, DTI still fine
    loan = @user.loan_applications.create!(amount: 10_000, purpose: "debt_consolidation", term_months: 36)
    decision = LoanDecisionEngine.new(loan).call
    assert_equal "manual_review", decision.decision
  end

  test "rejects a loan amount that exceeds 5x monthly income" do
    loan = @user.loan_applications.create!(amount: 1_000_000, purpose: "home_improvement", term_months: 60)
    decision = LoanDecisionEngine.new(loan).call
    assert_not_equal "approved", decision.decision
  end
end
