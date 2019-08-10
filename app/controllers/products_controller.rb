class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :buy, :pay]
  before_action :set_image, only: [:show, :buy, :pay]

  def index
    @products = Product.includes(:image).order("created_at DESC")
  end

  def show
    @user = User.find(@product.seller_id)
  end
  
  def new
    @product = Product.new
    @product.build_image
    # あとで使う    2.time{@product.images.build}
    @product.build_delivery
    @product.build_category
  end

  def create
    @product= Product.new(product_params)
    if @product.save!
      # あとで使う
      # params[:images]['image'].each do |a|
      #   @image = @product.images.create!(image: a, product_id: @product.id)
      # end
      redirect_to root_path, notice: '出品が完了しました。'
    else
      redirect_to new_product_path
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end


  def buy
    @credit = Credit.where(user_id: current_user.id).first if Credit.where(user_id: current_user.id).present?
    if @product.seller_id == current_user.id
      redirect_to product_path(@product)
    elsif @credit.blank?
      redirect_to credit_users_path
    else
      Payjp.api_key = Rails.application.credentials.PAYJP_SECRET_KEY
      customer = Payjp::Customer.retrieve(@credit.payjp_id)
      @default_credit_info = customer.cards.retrieve(@credit.card_id)
      @card_nam = @default_credit_info.last4
      @exp_month = @default_credit_info.exp_month
      @exp_year = @default_credit_info.exp_year.to_s.slice(2,3)
    end
  end

  def pay
    credit = Credit.where(user_id: current_user.id).first
    Payjp.api_key = Rails.application.credentials.PAYJP_SECRET_KEY
    Payjp::Charge.create(
    amount: @product.price, 
    customer: credit.payjp_id, 
    currency: 'jpy'
    )
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_image
    @image = Image.find_by(product_id:@product.id)
  end
  
  def product_params
    params.require(:product).permit(:name, :description, :condition_id, :price, :status, category_attributes: [:name_id, :product_id], image_attributes: [:image, :product_id], delivery_attributes: [:days_to_ship_id, :mode, :payment_id, :delivery_method, :prefecture_id, :mode]).merge(seller_id: current_user.id)
  end


end
