class Text < ActiveRecord::Base
	belongs_to :user
  	mount_uploader :path, TextUploader
end
