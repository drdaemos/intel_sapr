class TextsController < ApplicationController
	# GET /texts/
	def index
		text = Text.all
		render json: text
	end

	# GET /texts/:id
	def show
		id = params[:id]
		text = Text.find(id)
		render json: text
	end

	def create
		text = params[:text]
		text.permit!

		uploader = TextUploader.new
		uploader.retrieve_from_cache!(text['path'])

		text['path'] = uploader.file

		Text.create(text)

		render json: {:result => 'success'}
	end

private

	def text_params
		params.require(:text).permit(:name).permit(:description).permit(:user_id).permit(:deleted).permit(:type).permit(:path)
	end

end
