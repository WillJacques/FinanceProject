class Stock < ApplicationRecord # rubocop:disable Metrics/ClassLength
  require 'json'

  def calculate_mean_on_time_period(start_date: '2020-01-01', end_date: '2020-12-31', data: 'adj_close')
    results = fetch_data(start_date: start_date, end_date: end_date, stock_info: stock_info, data: data)
    results.mean
  end

  def calculate_roi_on_time_period(start_date: '2020-01-01', end_date: '2020-12-31', data: 'adj_close')
    results = fetch_data(start_date: start_date, end_date: end_date, stock_info: stock_info, data: data)
    results.variation
  end

  # verified
  def calculate_sd_on_time_period(start_date: '2020-01-01', end_date: '2020-12-31', data: 'daily_return')
    results = fetch_data(start_date: start_date, end_date: end_date, stock_info: stock_info, data: data)
    results.standard_deviation
  end

  # verified
  def calculate_variance_on_time_period(start_date: '2020-01-01', end_date: '2020-12-31', data: 'daily_return')
    results = fetch_data(start_date: start_date, end_date: end_date, stock_info: stock_info, data: data)
    results.sample_variance * results.size
  end

  def calculate_cov_on_time_period(start_date: '2020-01-01', end_date: '2020-12-31')
    mean = calculate_mean_on_time_period(start_date: start_date, end_date: end_date)
    sd = calculate_sd_on_time_period(start_date: start_date, end_date: end_date)
    return nil if mean.nil? || sd.nil?

    sd / mean
  end

  def info_for_candlestick
    results = []
    JSON.parse(stock_info).first(200).reverse_each do |info|
      line_result = []
      line_result.push(info['date'].to_datetime.strftime('%F'), info['low'].to_f, info['open'].to_f,
                       info['close'].to_f, info['high'].to_f)
      results.push(line_result)
    end
    results
  end

  def self.get_cov_and_roi(stocks: nil, start_date: '2020-01-01', end_date: '2020-12-31')
    stocks = Stock.where(symbol: stocks)
    stocks = Stock.first(100) if stocks.empty?
    results = []
    stocks.each_with_index do |stock, i|
      cov = stock.calculate_cov_on_time_period(start_date: start_date, end_date: end_date)
      roi = stock.calculate_roi_on_time_period(start_date: start_date, end_date: end_date)
      results << { id: stock.id, ticker: stock.symbol, cov: cov, roi: roi }
      puts "#{i} stocks analyzed on #{stocks.size}" if (i % 20).zero?
    rescue StandardError => e
      puts e
      puts stock.symbol
    end
    User.find_by(fullname: 'William Jacques').update(last_query: results.to_json)
  end

  def self.search_ticker_info(ticker: nil, company_name: nil)
    stock_info = find_stock(ticker)
    puts stock_info.inspect if stock_info['Error Message'].present?
    return false unless stock_info['Meta Data'].present?

    symbol = stock_info['Meta Data']['2. Symbol']
    stock_already_in_db = Stock.find_by(symbol: symbol.upcase)

    infos = stock_info['Time Series (Daily)']

    info_array = []
    last_day_close = nil
    infos.reverse_each do |key, value|
      daily_return = ((value['5. adjusted close'].to_f / last_day_close) - 1).to_s unless last_day_close.nil?
      last_day_close = value['5. adjusted close'].to_f
      hash = { date: key, open: value['1. open'], high: value['2. high'], low: value['3. low'],
               close: value['4. close'], adj_close: value['5. adjusted close'], daily_return: daily_return || '0' }
      info_array.unshift(hash)
    end

    if stock_already_in_db.present?
      stock_already_in_db.update(stock_info: info_array.to_json, company_name: company_name.strip,
                                 last_call_to_api: Time.now)
    else
      Stock.create(symbol: symbol.upcase, company_name: company_name&.strip, stock_info: info_array.to_json,
                   last_call_to_api: Time.now)
    end
    true
  end

  def self.search_ticker_info2(ticker: nil, company_name: nil)
    stock_info = find_stock2(ticker)
    puts stock_info.inspect if stock_info['Error Message'].present?
    return false unless stock_info['status'] == 'ok'

    symbol = stock_info['meta']['symbol']
    stock_already_in_db = Stock.find_by(symbol: symbol.upcase)

    infos = stock_info['values']

    info_array = []
    last_day_close = nil
    infos.reverse_each do |line|
      daily_return = ((line['close'].to_f / last_day_close) - 1).to_s unless last_day_close.nil?
      last_day_close = line['close'].to_f
      hash = { date: line['datetime'], open: line['open'], high: line['high'], low: line['low'],
               close: line['close'], adj_close: line['close'], daily_return: daily_return || '0' }
      info_array.unshift(hash)
    end

    if stock_already_in_db.present?
      stock_already_in_db.update(stock_info: info_array.to_json, company_name: company_name&.strip,
                                 last_call_to_api: Time.now)
    else
      Stock.create(symbol: symbol.upcase, company_name: company_name&.strip, stock_info: info_array.to_json,
                   last_call_to_api: Time.now)
    end
    true
  end

  def self.search_profile_info(symbol: nil)
    stock_already_in_db = Stock.find_by(symbol: symbol.upcase)
    return false if stock_already_in_db.nil?

    stock_profile = find_profile(symbol)
    return false if stock_profile.nil?

    puts stock_profile.inspect if stock_profile['error'].present?
    return false if stock_profile['error'].present?

    sector = stock_profile['sector']

    stock_already_in_db.update(sector: sector) if stock_already_in_db.present?
  end

  # validated
  def self.create_correlation_matrix(stocks: nil, start_date: '2020-01-01', end_date: '2020-12-31')
    stocks = Stock.where(symbol: stocks)
    stocks = Stock.first(5) if stocks.empty?
    results = []
    y_max = nil
    stocks.each_with_index do |stock, i|
      stock_info = JSON.parse(stock.stock_info).select do |info|
        info['date'].to_date.between?(start_date.to_date, end_date.to_date)
      end
      y_max ||= stock_info.size
      y_index = 0
      while y_index < y_max
        if i.zero? && y_index.zero?
          results = [['Date', stock.symbol]]
          results.push([stock_info[y_index]['date'], stock_info[y_index]['daily_return'].to_f])
        elsif i.zero? && y_index != 0
          results.push([stock_info[y_index]['date'], stock_info[y_index]['daily_return'].to_f])
        elsif i != 0 && y_index.zero?
          results[0].push(stock.symbol)
          results[1].push(stock_info[y_index]['daily_return'].to_f)
        else
          value = begin
            stock_info[y_index]['daily_return'].to_f
          rescue StandardError
            0
          end
          results[y_index + 1].push(value)
        end
        y_index += 1
      end
    end
    formatted_table = correlation_coefficient_table(results)
    User.first.update(last_query: formatted_table.to_json)
    formatted_table
  end

  def self.create_covariance_matrix(stocks: nil, start_date: '2020-01-01', end_date: '2020-12-31')
    stocks = Stock.where(symbol: stocks)
    stocks = Stock.first(5) if stocks.empty?
    results = []
    y_max = nil
    stocks.each_with_index do |stock, i|
      stock_info = JSON.parse(stock.stock_info).select do |info|
        info['date'].to_date.between?(start_date.to_date, end_date.to_date)
      end
      y_max ||= stock_info.size
      y_index = 0
      while y_index < y_max
        if i.zero? && y_index.zero?
          results = [['Date', stock.symbol]]
          results.push([stock_info[y_index]['date'], stock_info[y_index]['daily_return'].to_f])
        elsif i.zero? && y_index != 0
          results.push([stock_info[y_index]['date'], stock_info[y_index]['daily_return'].to_f])
        elsif i != 0 && y_index.zero?
          results[0].push(stock.symbol)
          results[1].push(stock_info[y_index]['daily_return'].to_f)
        else
          value = begin
            stock_info[y_index]['daily_return'].to_f
          rescue StandardError
            0
          end
          results[y_index + 1].push(value)
        end
        y_index += 1
      end
    end
    formatted_table = covariance_table(results)
    User.first.update(last_query: formatted_table.to_json)
    formatted_table
  end

  def self.create_covariance_matrix_no_headers(stocks: nil, start_date: '2020-01-01', end_date: '2020-12-31')
    stocks = Stock.where(symbol: stocks)
    stocks = Stock.first(3) if stocks.empty?
    results = []
    stocks.each do |stock|
      stock_info = JSON.parse(stock.stock_info).select do |info|
        info['date'].to_date.between?(start_date.to_date, end_date.to_date)
      end
      array = stock_info.map { |info| info['daily_return'].to_f }
      results.push(array)
    end
    formatted_table = covariance_table_no_header(results)
    User.first.update(last_query: formatted_table.to_json)
    formatted_table
  end

  private

  def fetch_data(start_date:, end_date:, stock_info:, data:)
    JSON.parse(stock_info).select { |info| info['date'].between?(start_date, end_date) }.map { |info| info[data].to_f }
  end

  class << self
    def correlation_coefficient_table(result_array)
      n = result_array[0].length - 1
      array_for_cc = result_array.drop(1).transpose.drop(1)

      table = [result_array[0].drop(1)]
      n.times do |x|
        table_line = []
        n.times do |y|
          table_line << '1.000000' if x == y
          next if x <= y

          table_line << [array_for_cc[x], array_for_cc[y]].correlation
        end
        table << table_line
      end
      format_table(table)
    end

    def covariance_table(result_array)
      n = result_array[0].length - 1
      array_for_cov = result_array.drop(1).transpose.drop(1)

      table = [result_array[0].drop(1)]
      n.times do |x|
        table_line = []
        n.times do |y|
          next if x < y

          table_line << ([array_for_cov[x], array_for_cov[y]].coefficent_of_variation * 253).round(6)
        end
        table << table_line
      end
      format_table(table)
    end

    def covariance_table_no_header(result_array)
      array_for_cov = result_array.transpose
      n = array_for_cov.last.length

      table = []
      n.times do |x|
        table_line = []
        n.times do |y|
          next if x < y

          table_line << ([array_for_cov[x], array_for_cov[y]].coefficent_of_variation * 253).round(6)
        end
        table << table_line
      end
      format_table_no_header(table)
    end

    def format_table(table)
      size = table[0].length
      table_to_format = table.drop(1)
      result_table = [table[0].unshift('')]
      size.times do |y|
        table_line = [table[0][y + 1]]
        size.times do |x|
          value = table_to_format[y][x] || table_to_format[x][y]
          table_line << value
        end
        result_table << table_line
      end
      result_table
    end

    def format_table_no_header(table)
      size = table.last.length
      result_table = []
      size.times do |y|
        table_line = []
        size.times do |x|
          value = table[y][x] || table[x][y]
          table_line << value
        end
        result_table << table_line
      end
      result_table
    end

    def request_api(url)
      response = Excon.get(
        url,
        headers: {
          'X-RapidAPI-Host' => 'alpha-vantage.p.rapidapi.com',
          'X-RapidAPI-Key' => 'APIKEY'
        }
      )
      return nil if response.status != 200

      JSON.parse(response.body)
    end

    def request_api2(url)
      response = Excon.get(
        url,
        headers: {
          'X-RapidAPI-Host' => 'twelve-data1.p.rapidapi.com',
          'X-RapidAPI-Key' => 'APIKEY'
        }
      )
      return nil if response.status != 200

      JSON.parse(response.body)
    end

    def find_stock(code)
      request_api(
        "https://alpha-vantage.p.rapidapi.com/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=#{code}&outputsize=full&datatype=json"
      )
    end

    def find_stock2(code)
      request_api2(
        "https://twelve-data1.p.rapidapi.com/time_series?symbol=#{code}&outputsize=5000&interval=1day&format=json"
      )
    end

    def find_profile(code)
      request_api2(
        "https://api.polygon.io/v1/meta/symbols/#{code}/company?apiKey=APIKEY"
      )
    end
  end
end
