require 'yaml'
require 'ots'

class SummarizeStep < AnalysisStep
	STEP_GROUP = 'summarize'
	attr_reader :data, :text
	def initialize (data, text)
		@data = data
		@text = text
	end

	def proceed!
		summary = OTS.parse(@data, dictionary: Rails.root.join('config', 'ru.xml'))
		words = summary.keywords.take(25).join(' ')
		IntelSapr.logger.debug words
		lemmas = Stemmer.new.stem(words)
		keywords = lemmas.reduce(Array.new) {
			|text, word| text.append(word['analysis'][0]['lex'])
		}
		stats = {
			'summary' => summary.summarize(percent: 10),
			'keywords' => keywords.uniq.take(5),
		}

		stats.each {
			|key, value| Metric.create({ :text => @text, :key => key, :value => value.to_json, :group => STEP_GROUP })
		}
	end

private

end