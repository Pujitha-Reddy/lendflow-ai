class LoanApplicationsController < ApplicationController
  def create
    user = User.find(params[:loan_application][:user_id])
    loan_application = user.loan_applications.new(loan_application_params)
    if loan_application.save
      render json: loan_application, status: :created
    else
      render json: { errors: loan_application.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def show
    loan_application = LoanApplication.find(params[:id])
    render json: loan_application.as_json(include: [ :user, :loan_decision ])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Loan application not found" }, status: :not_found
  end

  private

  def loan_application_params
    params.require(:loan_application).permit(:amount, :purpose, :term_months)
  end
end
