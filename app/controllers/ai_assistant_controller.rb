class AiAssistantController < ApplicationController
  def chat
    question = params[:question]

    if question.blank?
      render json: { error: "question parameter is required" }, status: :unprocessable_entity
      return
    end

    result = AiAssistantService.answer(question)
    render json: result
  end
end