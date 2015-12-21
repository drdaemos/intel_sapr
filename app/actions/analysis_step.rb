class AnalysisStep
	def proceed!
    	raise NotImplementedError, "Subclasses must define proceed()"
	end
end