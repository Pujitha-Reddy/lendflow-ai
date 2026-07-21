require "net/http"

class AiAssistantService
  GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
  MODEL = "llama-3.3-70b-versatile"

  def self.answer(question)
    documents = PolicyRetriever.relevant_documents(question)

    if documents.empty?
      return {
        answer: "I don't have policy information relevant to that question. Please contact support for details outside our standard lending policy.",
        sources: []
      }
    end

    context = documents.map { |doc| "### #{doc[:name].tr('_', ' ').upcase}\n#{doc[:content]}" }.join("\n\n")

    system_prompt = <<~SYSTEM
      You are a helpful assistant for LendFlow AI, a loan processing company. Answer the applicant's question using ONLY the policy information provided. Be concise and clear.

      IMPORTANT: You have NOT been given this specific applicant's data (credit score, income, etc.). Do not claim to know why THEIR specific application was approved or rejected. Instead, explain the general policy and, only if the question is about a personal decision, suggest they check their application's decision reason for their specific result.

      If the policy information doesn't fully answer the question, say so honestly rather than guessing.
    SYSTEM

    user_prompt = <<~USER
      POLICY INFORMATION:
      #{context}

      APPLICANT QUESTION:
      #{question}
    USER

    response = call_groq(system_prompt, user_prompt)

    {
      answer: response,
      sources: documents.map { |doc| doc[:name] }
    }
  end

  def self.call_groq(system_prompt, user_prompt)
    uri = URI(GROQ_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request["Authorization"] = "Bearer #{Rails.application.credentials.groq_api_key}"
    request.body = {
      model: MODEL,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ],
      temperature: 0.3
    }.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)

    if parsed["error"]
      Rails.logger.error("Groq API error: #{parsed['error']}")
      return "The assistant is currently unavailable. Please try again shortly."
    end

    parsed.dig("choices", 0, "message", "content")&.strip || "The assistant is currently unavailable."
  rescue => e
    Rails.logger.error("Groq call failed: #{e.message}")
    "The assistant is currently unavailable. Please try again shortly."
  end
end