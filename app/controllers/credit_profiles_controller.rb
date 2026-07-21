class CreditProfilesController < ApplicationController
  def create
    user = User.find(params[:user_id])
    credit_profile = user.build_credit_profile(credit_profile_params)
    if credit_profile.save
      render json: credit_profile, status: :created
    else
      render json: { errors: credit_profile.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def show
    user = User.find(params[:user_id])
    if user.credit_profile
      render json: user.credit_profile
    else
      render json: { error: "No credit profile on file" }, status: :not_found
    end
  end

  private

  def credit_profile_params
    params.require(:credit_profile).permit(:credit_score, :debt_to_income, :bankruptcies)
  end
end
