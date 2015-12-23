require 'open3'

class Stemmer

	def stem (input)
		run_mystem (input)
	end

private

	def run_mystem (input)
	  	require 'open3'
	  	command = 'mystem -nig --format json'
	  	out, status = Open3.capture2(command, :stdin_data => input)
		processed = out.lines.map { |e| JSON.parse(e) }

		filtered = processed.select { |i| i['analysis'].any? }

		return filtered
	end
end