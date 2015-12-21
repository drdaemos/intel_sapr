require 'yaml'
class StatisticStep < AnalysisStep
	STEP_GROUP = 'statistic'
	attr_reader :data, :text
	def initialize (data, text)
		@data = data
		@text = text
	end

	def proceed!
		bigrams = ngrams(2, @data)
		raw_freq_bigrams = count_frequency(bigrams)
		raw_freq = count_frequency(@data)
		mutual = bigrams.reduce(Hash.new(0)) {
			|hash, bigram| hash[bigram.join(' ')] = count_mutual_information(bigram, raw_freq_bigrams, raw_freq); hash
		}

		stats = {
			'raw_frequency' => raw_freq_bigrams.sort_by{|k,v| v}.reverse.to_h,
			'mutual' => mutual.sort_by{|k,v| v}.reverse.to_h,
		}

		stats.each {
			|key, value| Metric.create({ :text => @text, :key => key, :value => value, :group => STEP_GROUP })
		}
	end

private

	def ngrams(n, words)
		IntelSapr.logger.error words
	  	words.each_cons(n).to_a
	end

	def count_frequency (array)
		raw_freq = array.reduce(Hash.new(0)) {
			|freq, item| key = item.kind_of?(Array) ? item.join(' ') : item.to_s ; freq[key] += 1; freq
		}
	end

	def count_mutual_information (bigram, raw_freq_bi, raw_freq)
		bi_freq = raw_freq_bi[bigram.join(' ')]
		first_freq = raw_freq[bigram.first]
		last_freq = raw_freq[bigram.last]
		mutual = Math.log2 ((bi_freq * @data.count) / (first_freq.to_f * last_freq))
	end
end