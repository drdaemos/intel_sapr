class Text < ActiveRecord::Base
	belongs_to :user
	has_many :metrics, dependent: :destroy
  	mount_uploader :path, TextUploader
end
