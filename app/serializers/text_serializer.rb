class TextSerializer < ActiveModel::Serializer
	has_many :metrics, serializer: MetricSerializer
  	attributes :id, :name, :description, :path, :type, :deleted


	def filter(keys)
		unless @except.nil?
			@except.each {|value| keys.delete value}
		end
	    keys
	end
end
