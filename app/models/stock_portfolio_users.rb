class StockPortfolioUsers < ApplicationRecord
  belongs_to :user
  belongs_to :portfolio
  belongs_to :stock

  require 'matrix'

  def self.calculate_portfolio_variance(portfolio_id: 1, start_date: '2020-01-01', end_date: '2020-12-31')
    portfolio_stocks = StockPortfolioUsers.where(portfolio_id: portfolio_id)
    portfolio_value = portfolio_stocks.reduce(0) { |sum, obj| sum + (obj.stock_value * obj.stock_quantity) }
    infos = []
    portfolio_stocks.each do |portfolio_stock|
      stock_info = JSON.parse(portfolio_stock.stock.stock_info).select do |date|
        date['date'].between?(start_date, end_date)
      end
      info = {}
      info[:symbol] = portfolio_stock.stock.symbol
      info[:daily_return] = stock_info.map { |close| close['daily_return'].to_f }
      info[:sd] = portfolio_stock.stock.calculate_sd_on_time_period
      info[:value] = portfolio_stock.stock_value * portfolio_stock.stock_quantity
      info[:weight] = portfolio_stock.stock_value * portfolio_stock.stock_quantity / portfolio_value
      infos << info
    end
    arrays = [infos[0][:daily_return], infos[1][:daily_return]]
    first = infos[0][:weight]**2 * infos[0][:sd]**2
    second = infos[1][:weight]**2 * infos[1][:sd]**2
    size = infos[0][:daily_return].size
    third = 2 * infos[0][:weight] * infos[1][:weight] * infos[0][:sd] * infos[1][:sd] * arrays.correlation

    portfolio_variance = (first + second + third) * size
    portfolio_variance.round(8).to_s
  end

  def self.calculate_portfolio_variance2(portfolio_id: 1, start_date: '2020-01-01', end_date: '2020-12-31')
    portfolio_stocks = StockPortfolioUsers.where(portfolio_id: portfolio_id)
    portfolio_value = portfolio_stocks.reduce(0) { |sum, obj| sum + (obj.stock_value * obj.stock_quantity) }
    weights = []
    stocks = []
    portfolio_stocks.each do |portfolio_stock|
      weights << (portfolio_stock.stock_value * portfolio_stock.stock_quantity / portfolio_value).round(6).to_f
      stocks << portfolio_stock.stock.symbol
    end
    pp weights
    nested_table = Stock.create_covariance_matrix_no_headers(stocks: stocks, start_date: start_date, end_date: end_date)
    weight_by_days = weights.map { |n| n * 253 }
    weight_transpose = []
    weights.each do |weight|
      weight_transpose.push(weight)
    end
    portfolio_variance = [[weight_by_days, nested_table].multiply_matrix, weight_transpose].multiply_matrix
    portfolio_variance.round(8).to_s
  end
end
