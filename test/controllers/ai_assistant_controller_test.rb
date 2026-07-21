require "test_helper"

class AiAssistantControllerTest < ActionDispatch::IntegrationTest
  test "returns an answer and sources for a valid question" do
    post "/ai/chat", params: { question: "What documents are required to apply?" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["answer"].present?
    assert json["sources"].present?
  end

  test "returns an error when question is missing" do
    post "/ai/chat", params: {}, as: :json

    assert_response :unprocessable_entity
  end
end
