class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: %i[show edit update destroy candlestick]

  # GET /stocks or /stocks.json
  def index
    @stocks = Stock.paginate(page: params[:page], per_page: 50).order(:symbol)
  end

  # GET /stocks/1 or /stocks/1.json
  def show
    @infos = JSON.parse(Stock.find_by(id: params[:id]).stock_info)
  end

  def candlestick
    @data = @stock.info_for_candlestick
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit; end

  # POST /stocks or /stocks.json

  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    response = Stock.search_ticker_info2(ticker: params[:ticker])
    if response
      redirect_to stocks_url, notice: 'Stock successfully loaded !'
    else
      redirect_to stocks_url, alert: 'Stock not found !'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stock
    @stock = Stock.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def stock_params
    params.fetch(:stock, {})
  end
end
