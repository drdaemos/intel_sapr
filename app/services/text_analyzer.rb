class TextAnalyzer
	def analyze (model)
		text = File.read(model.path.path);
		step = MorphologicStep.new(text, model)
		step.proceed!
	end
end