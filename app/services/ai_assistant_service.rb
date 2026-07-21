require "net/http"

class AiAssistantService
  OLLAMA_URL = "http://localhost:11434/api/generate"
  MODEL = "llama3.2"

  def self.answer(question)
    documents = PolicyRetriever.relevant_documents(question)

    if documents.empty?
      return {
        answer: "I don't have policy information relevant to that question. Please contact support for details outside our standard lending policy.",
        sources: []
      }
    end

    context = documents.map { |doc| "### #{doc[:name].tr('_', ' ').upcase}\n#{doc[:content]}" }.join("\n\n")

    prompt = <<~PROMPT
  You are a helpful assistant for LendFlow AI, a loan processing company. Answer the applicant's question using ONLY the policy information below. Be concise and clear.

  IMPORTANT: You have NOT been given this specific applicant's data (credit score, income, etc.). Do not claim to know why THEIR specific application was approved or rejected. Instead, explain the general policy — what criteria matter and how decisions are made — and suggest they check their application's decision reason for their specific result.

  If the policy information doesn't fully answer the question, say so honestly rather than guessing.
  
      POLICY INFORMATION:
      #{context}

      APPLICANT QUESTION:
      #{question}

      ANSWER:
    PROMPT

    response = call_ollama(prompt)

    {
      answer: response,
      sources: documents.map { |doc| doc[:name] }
    }
  end

  def self.call_ollama(prompt)
    uri = URI(OLLAMA_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { model: MODEL, prompt: prompt, stream: false }.to_json

    response = http.request(request)
    JSON.parse(response.body)["response"]&.strip || "The assistant is currently unavailable."
  rescue => e
    Rails.logger.error("Ollama call failed: #{e.message}")
    "The assistant is currently unavailable. Please try again shortly."
  end
end