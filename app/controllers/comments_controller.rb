class CommentsController < ApplicationController

	def create
		# byebug
		@product = Product.find(params[:product_id])
		@comment = @product.comments.create(comment_params)
		@comment.user = current_user
		@user = current_user
		respond_to do |format|
			if @comment.save
				# ActionCable.server.broadcast 'product_channel', comment: @comment
				# ProductChannel.broadcast_to @product.id, comment: @comment
				# ProductChannel.broadcast_to @product.id, comment: CommentsController.render(partial: 'comments/comment', locals: {comment: @comment})
				ProductChannel.broadcast_to @product.id, comment: CommentsController.render(partial: 'comments/comment', locals: {comment: @comment, current_user: current_user})
				format.html { redirect_to @product, notice: "Review has been submitted successfully." }
				format.json { render :show, status: :created, location: @product }
				format.js
			else
				format.html { redirect_to @product, alert: 'Review was not saved successfully.' }
				format.json { render json: @comment.errors, status: :unprocessable_entity }
			end
		end

	end

	# def index
 #    	@comments = @comment.paginate(:page => params[:page], :per_page => 5)

 #  	end

	def destroy
		@comment = Comment.find(params[:id])
		product = @comment.product
		@comment.destroy
		redirect_to product
	end

	private

		def comment_params
    		params.require(:comment).permit(:user_id, :body, :rating)
  		end
end