class LemmaController < ApplicationController
  def index
  end

  def result
  	require 'open3'
  	input = params[:text]
  	command = 'mystem -nig --format json'
  	out, status = Open3.capture2(command, :stdin_data => input)
	processed = out.lines.map { |e| JSON.parse(e) }

	filtered = processed.select { |i| i['analysis'].any? }

	@stats = {
		'Verbs' => filtered.reduce(0) {
			|count, word| word['analysis'][0]['gr'].chars.first == 'V' ? count.next : count
		},
		'Nouns female' => filtered.reduce(0) {
			|count, word| word['analysis'][0]['gr'].chars.first == 'S' && word['analysis'][0]['gr'] =~ /,жен,/ ? count.next : count
		},
		'Adjectives' => filtered.reduce(0) {
			|count, word| word['analysis'][0]['gr'] =~ /A[,=]/ ? count.next : count
		},
		'Nouns plural' => filtered.reduce(0) {
			|count, word| word['analysis'][0]['gr'] =~ /S[,=]/ && word['analysis'][0]['gr'] =~ /мн/ ? count.next : count
		},
		'Verbs in past tense' => filtered.reduce(0) {
			|count, word| word['analysis'][0]['gr'] =~ /V[,=]/ && word['analysis'][0]['gr'] =~ /прош/ ? count.next : count
		},
	}

  	@data = {'input' => input, 'lemmatized' => '', 'status' => status, 'processed' => processed}
  end
end
