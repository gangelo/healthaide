module Admin
  class FoodsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin
    before_action :set_food, only: [ :show, :edit, :update, :destroy, :add_qualifier, :remove_qualifier ]

    def index
      @foods = Food.all
    end

    def show; end

    def new
      @food = Food.new
    end

    def edit; end

    def create
      @food = Food.new(food_params)

      if @food.save
        redirect_to admin_food_path(@food), notice: "Food was successfully created."
      else
        render :new
      end
    end

    def update
      if @food.update(food_params)
        redirect_to admin_food_path(@food), notice: "Food was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @food.soft_delete
      redirect_to admin_foods_path, notice: "Food was successfully deleted."
    end

    def add_qualifier
      @qualifier = FoodQualifier.find(params[:qualifier_id])

      if @food.food_qualifiers.include?(@qualifier)
        flash[:notice] = "#{@qualifier.qualifier_name} is already associated with this food."
      else
        @food.food_qualifiers << @qualifier
        flash[:success] = "Added #{@qualifier.qualifier_name} to #{@food.food_name}."
      end

      redirect_to admin_food_path(@food)
    end

    def remove_qualifier
      @qualifier = FoodQualifier.find(params[:qualifier_id])

      if @food.food_qualifiers.include?(@qualifier)
        @food.food_qualifiers.delete(@qualifier)
        flash[:success] = "Removed #{@qualifier.qualifier_name} from #{@food.food_name}."
      else
        flash[:notice] = "#{@qualifier.qualifier_name} is not associated with this food."
      end

      redirect_to admin_food_path(@food)
    end

    private

    def set_food
      @food = Food.find(params[:id])
    end

    def food_params
      params.require(:food).permit(:food_name)
    end

    def ensure_admin
      # Implement your admin check here, for example:
      redirect_to root_path, alert: "Not authorized." unless current_user.admin?
    end
  end
end
