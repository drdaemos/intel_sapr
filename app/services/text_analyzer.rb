require 'yomu'

class TextAnalyzer
	def analyze (text)
		data = File.read(text.path.path);
		input = Yomu.read :text, data
		text.metrics.clear
		MorphologicStep.new(input, text).proceed!
		lemmatized = JSON::parse text.metrics.find_by(group: MorphologicStep::STEP_GROUP, key: 'text').value
		StatisticStep.new(lemmatized, text).proceed!
		SummarizeStep.new(input, text).proceed!
	end
  	handle_asynchronously :analyze
end