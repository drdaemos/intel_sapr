require 'yaml'
require 'bloom-filter'

class MorphologicStep < AnalysisStep
	STEP_GROUP = 'morphologic'
	attr_reader :data, :filter, :text
	def initialize (data, text)
		@data = data
		@text = text
		cache = Rails.root.join('tmp', 'stoplist.bloom')

		if File.exists? cache
			@filter = BloomFilter.load cache
		else
			@filter = BloomFilter.new size: Global.resources.stoplist.count
			Global.resources.stoplist.each {
				|word| @filter.insert word
			}
			@filter.dump cache
		end
	end

	def proceed!

		lemma = Stemmer.new.stem(@data)

		parse_lemma(lemma)
	end

private

	def parse_lemma (lemma)
		stats = {
			'text' => lemma.reduce(Array.new) {
				|text, word| text.append(word['analysis'][0]['lex'])
			},
			'verbs' => lemma.reduce(0) {
				|count, word| word['analysis'][0]['gr'].chars.first == 'V' ? count.next : count
			},
			'nouns' => lemma.reduce(0) {
				|count, word| word['analysis'][0]['gr'].chars.first == 'S' ? count.next : count
			},
			'adjectives' => lemma.reduce(0) {
				|count, word| word['analysis'][0]['gr'] =~ /A[,=]/ ? count.next : count
			},
		}

		stats['text'].select! {
			|word| not @filter.include? word
		}

		stats.each {
			|key, value| Metric.create({ :text => @text, :key => key, :value => value.to_json, :group => STEP_GROUP })
		}
	end
end