class UploadController < ApplicationController
  def upload
  	uploaded = params[:file]

  	uploader = TextUploader.new
	uploader.cache!(uploaded)

	response = {:file => uploader.cache_name}
  	render json: JSON.generate(response)
  end
end
