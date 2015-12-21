class TextSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :path, :type, :deleted
end
