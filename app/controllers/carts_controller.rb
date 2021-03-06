class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_cart
  before_action :load_product, only: %i(add change)
  before_action :load_categories, only: :index
  before_action :check_cart, only: :index
  before_action :load_items, only: :index

  def index; end

  def add
    if check_quantity?
      cart_contain = CartContain.new product_id: @product.id,
        quantity: params[:quantity].to_i, price: @product.price
      add_to_cart cart_contain
      session[:cart] = @cart
      render json: {err: Settings.err.not_err, quantity: count_quantity}
    else
      render json: {err: Settings.err.not_enought_quantity}
    end
  end

  def change
    if check_new_quantity?
      @cart[params[:product_id]]["quantity"] = params[:new_quantity].to_i
      session[:cart] = @cart
      total = params[:new_quantity].to_i * @product.price
      render json: {err: Settings.err.not_err, sum_quantity: count_quantity,
                    total: total, grand_total: calculate_grand_total}
    else
      render json: {err: Settings.err.not_enought_quantity}
    end
  end

  def remove
    @cart.reject!{|key, _value| key == params[:id]}
    session[:cart] = @cart
    redirect_to carts_path
  end

  private

  def load_product
    @product = Product.find_by id: params[:product_id]
    render json: {err: Settings.err.product_not_found} if @product.blank?
  end

  def add_to_cart item
    if @cart[params[:product_id]]
      @cart[params[:product_id]]["quantity"] += params[:quantity].to_i
    else
      @cart[@product.id] = item
    end
  end

  def check_quantity?
    quantity = params[:quantity].to_i
    quantity += @cart[params[:product_id]]["quantity"] if is_exists_item_in_cart?
    return false if quantity > @product.quantity
    true
  end

  def is_exists_item_in_cart?
    @cart.present? && @cart[params[:product_id]].present?
  end

  def load_categories
    @categories = Category.get_parent_categories
  end

  def check_new_quantity?
    params[:new_quantity].present? && params[:new_quantity].to_i <= @product.quantity
  end
end
