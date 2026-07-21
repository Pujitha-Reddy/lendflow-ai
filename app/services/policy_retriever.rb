class PolicyRetriever
  POLICIES_PATH = Rails.root.join("app", "data", "policies")

  def self.relevant_documents(question, top_n: 2)
    question_words = question.downcase.scan(/\w+/).to_set

    scored = Dir.glob(POLICIES_PATH.join("*.txt")).map do |path|
      content = File.read(path)
      content_words = content.downcase.scan(/\w+/)
      score = content_words.count { |word| question_words.include?(word) }
      { name: File.basename(path, ".txt"), content: content, score: score }
    end

    scored.sort_by { |doc| -doc[:score] }.first(top_n).select { |doc| doc[:score] > 0 }
  end
end
