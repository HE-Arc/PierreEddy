class LotsController < ApplicationController
	def show
		@lot = Lot.find(params[:id])
		
	end	

	def index
		@lots = Lot.where(user_id: current_user.id)
	end

	def new
		@parentLot = Lot.new
		@categorie = Categorie.new
		@categories = Categorie.all
		@lot = Lot.new
	end
	
	def addChild
		@parentLot = Lot.find(params[:id])
		@lot = Lot.new
		@categorie = Categorie.new
		@categories = Categorie.all
	end

	def create 		
		@lot = Lot.new(get_params)
		@lot.user_id = current_user.id
			if @lot.parent_id
				@parent = Lot.find(@lot.parent_id)
				@parent.price_sold += @lot.price_sold
				@lot.date_buy = @parent.date_buy
				@parent.save
				@lot.save
			end
		if @lot.save
			redirect_to @lot
		else
			render 'new'
		end
	end	

	def edit
		@lot = Lot.find(params[:id])
		if @lot.parent_id
			@parentLot = Lot.find(@lot.parent_id)
		else
			@parentLot = Lot.new
		end
		@categorie = Categorie.new
		@categories = Categorie.all
	end

	def update
		@lot = Lot.find(params[:id])
		if @lot.update(get_params)
			if @lot.parent_id
				@parent = Lot.find(@lot.parent_id)
				@parent.price_sold = 0
				@children = Lot.where(parent_id: @parent.id)
				@children.each do |l|
					@parent.price_sold += l.price_sold
				end
				@lot.date_buy = @parent.date_buy
				@parent.save
				@lot.save
			end
			redirect_to @lot
		else
			render 'edit'
		end
	end

	def destroy
		@lot = Lot.find(params[:id])
		@lots = Lot.where(parent_id: @lot.id)
		@lots.each do |l|
			l.destroy
		end
		@lot.destroy
		redirect_to lots_path
	end

	private
	def get_params
		params[:lot].permit(:name,:description,:date_buy,:date_sold,:price_buy,:price_sold,:price_estimated,:categorie_id,:parent_id,:user_id,:created_at)
	end
end