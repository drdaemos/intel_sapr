class User < ActiveRecord::Base
	has_many :texts, dependent: :destroy


end
