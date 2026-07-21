class LoanDecisionsController < ApplicationController
  def create
    loan_application = LoanApplication.find(params[:loan_application_id])
    decision = LoanDecisionEngine.new(loan_application).call
    render json: decision, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Loan application not found" }, status: :not_found
  end

  def show
    loan_application = LoanApplication.find(params[:loan_application_id])
    if loan_application.loan_decision
      render json: loan_application.loan_decision
    else
      render json: { error: "No decision yet — POST to this endpoint first" }, status: :not_found
    end
  end
end
