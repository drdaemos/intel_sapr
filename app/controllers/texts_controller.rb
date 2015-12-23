class TextsController < ApplicationController
	# GET /texts/
	def index
		text = Text.order(created_at: :desc)
		# render json: text, except: [:metrics]
		render json: text
	end

	# GET /texts/:id
	def show
		id = params[:id]
		text = Text.find(id)
		render json: text
	end

	# POST /texts/analyze/:id
	def analyze
		id = params[:id]
		text = Text.find(id)
		text.analyze
		render json: {:result => 'success'}
	end

	# POST /texts/
	def create
		text = params[:text]
		text.permit!

		uploader = TextUploader.new
		uploader.retrieve_from_cache!(text['path'])

		text['path'] = uploader.file

		Text.create(text)
		text.analyze

		render json: {:result => 'success'}
	end

private

	def text_params
		params.require(:text).permit(:name).permit(:description).permit(:user_id).permit(:deleted).permit(:type).permit(:path)
	end

end
