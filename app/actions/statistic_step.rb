require 'yaml'

class StatisticStep < AnalysisStep
	STEP_GROUP = 'statistic'
	attr_reader :data, :text
	attr_accessor :bigrams
	def initialize (data, text)
		@data = data
		@text = text
	end

	def proceed!
		@bigrams = ngrams(3, @data)
		raw_freq_bigrams = count_frequency(@bigrams)
		bigrams_count = @bigrams.count
		raw_freq = count_frequency(@data)
		container = {
			'raw_frequency' => raw_freq_bigrams,
			'mutual' => Hash.new,
			't_score' => Hash.new,
			'log_likelihood' => Hash.new,
		}
		stats = @bigrams.reduce(container) {
			|container, bigram| \
			container['mutual'][bigram.join(' ')] = count_mutual_information(bigram, raw_freq_bigrams, raw_freq, bigrams_count); \
			container['t_score'][bigram.join(' ')] = count_t_score(bigram, raw_freq_bigrams, raw_freq, bigrams_count); \
			container['log_likelihood'][bigram.join(' ')] = count_log_likelihood(bigram, raw_freq_bigrams, raw_freq, bigrams_count); \
			container
		}

		stats.each {|stat, values| stats[stat] = values.sort_by{|k,v| v}.reverse.to_h}

		stats.each {
			|key, value| Metric.create({ :text => @text, :key => key, :value => value, :group => STEP_GROUP })
		}
	end

private

	def ngrams(n, words)
	  	words.each_cons(n).to_a
	end

	def count_frequency (array)
		raw_freq = array.reduce(Hash.new(0)) {
			|freq, item| key = item.kind_of?(Array) ? item.join(' ') : item.to_s ; freq[key] += 1; freq
		}
	end

	def count_mutual_information (bigram, raw_freq_bi, raw_freq, bigrams_count)
		if raw_freq_bi[bigram.join(' ')]
			bi_prob = raw_freq_bi[bigram.join(' ')] / bigrams_count.to_f
			first_prob = raw_freq[bigram.first] / @data.count.to_f
			last_prob = raw_freq[bigram.last] / @data.count.to_f
			mutual = Math.log2 (bi_prob / (first_prob.to_f * last_prob))
		else
			return 0
		end
	end

	def count_t_score (bigram, raw_freq_bi, raw_freq, bigrams_count)
		if raw_freq_bi[bigram.join(' ')]
			bi_freq = raw_freq_bi[bigram.join(' ')]
			first_freq = raw_freq[bigram.first]
			last_freq = raw_freq[bigram.last]

			t_score = (bi_freq - (first_freq * last_freq / bigrams_count.to_f)) / (bi_freq ** 2)
		else
			return 0
		end
	end

	def count_log_likelihood (bigram, raw_freq_bi, raw_freq, bigrams_count)
		a = raw_freq_bi[bigram.join(' ')] / bigrams_count.to_f
		params = @bigrams.reduce (Hash.new(0.0)) {
			|params, item| \
			if item.first != bigram.first && item.last != bigram.last then \
				params['d'] += 1 \
			elsif item.first == bigram.first && item.last != bigram.last then \
				params['b'] += 1 \
			elsif item.first != bigram.first && item.last == bigram.last then \
				params['c'] += 1 \
			end; params
		}

		params.each {|key, value| params[key] = value.to_f / bigrams_count }
		b = params['b'] || 0.0
		c = params['c'] || 0.0
		d = params['d'] || 0.0

		ll = a * Math.log2(a+1) + b * Math.log2(b+1) + c * Math.log2(c+1) + d * Math.log2(d+1) + (a+b) * Math.log2(a+b+1) + (a+c) * Math.log2(a+c+1) + (b+d) * Math.log2(b+d+1) + (c+d) * Math.log2(c+d+1) + (a+b+c+d) * Math.log2(a+b+c+d+1)
	end
end