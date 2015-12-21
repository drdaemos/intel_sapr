class AuthController < ApplicationController
	def token
		render json: {:success => ''}
	end

	def cors
	  if request.method == 'OPTIONS'
	    headers['Access-Control-Allow-Origin'] = '*'
	    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
	    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
	    headers['Access-Control-Max-Age'] = '1728000'
	    render :text => ''
	  end
	end
end
