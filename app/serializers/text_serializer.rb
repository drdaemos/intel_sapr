class TextSerializer < ActiveModel::Serializer
	has_many :metrics
  	attributes :id, :name, :description, :path, :type, :deleted
end
