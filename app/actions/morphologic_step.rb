require 'yaml'
class MorphologicStep < AnalysisStep
	STEP_GROUP = 'morphologic'
	attr_reader :data, :stoplist, :text
	def initialize (data, text)
		@data = data
		@text = text
		@stoplist = Global.resources.stoplist
	end

	def proceed!
		lemma = run_mystem(@data)

		parse_lemma(lemma)
	end

private

	def run_mystem (input)
	  	require 'open3'
	  	command = 'mystem -nig --format json'
	  	out, status = Open3.capture2(command, :stdin_data => input)
		processed = out.lines.map { |e| JSON.parse(e) }

		filtered = processed.select { |i| i['analysis'].any? and not @stoplist.include? i['analysis'][0]['lex'] }

		return filtered
	end

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

		stats.each {
			|key, value| Metric.create({ :text => @text, :key => key, :value => value, :group => STEP_GROUP })
		}
	end
end