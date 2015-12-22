class MetricSerializer < ActiveModel::Serializer
  	attributes :key, :value, :group
end
