require 'csv'

namespace :stocks do # rubocop:disable Metrics/BlockLength
  desc 'Add tickers to user profile'
  task :add_stock_to_user_id, [:id] => :environment do |_t, args|
    csv_file_path = Rails.root.join('db/Wilshire-5000-Stocks.csv')
    csv_options = { headers: :first_row, header_converters: :symbol }
    puts 'Loading tickers from csv file...'
    ticker_array = []
    CSV.foreach(csv_file_path, **csv_options) do |row|
      ticker_array << [row[:ticker], row[:company]]
    end
    array_of_hashes = []
    ticker_array.each { |record| array_of_hashes << { 'ticker' => record[0], 'company_name' => record[1] } }

    User.find_by(id: args.id).update(stock_list: array_of_hashes.to_json)
    puts 'Done!'
  end

  desc 'Load some stock from user stock_list'
  task load_stock_info_from_stock_list: :environment do
    user = User.find_by(email: 'willy321@hotmail.com')
    json = JSON.parse(user.stock_list)
    first_stock = user.last_stock_updated + 1
    last_stock = user.last_stock_updated + 500

    puts 'Loading tickers from stock_list...'
    json[first_stock..last_stock].each_with_index do |stock, i|
      ok = Stock.search_ticker_info(ticker: stock['ticker'], company_name: stock['company_name'].strip)
      if ok
        user.update(last_stock_updated: first_stock + i)
        user.update(last_stock_updated: 0) if stock['ticker'] == 'ZNGA'
        sleep 20
      else
        puts "Problems with #{stock['company_name'].strip}"
      end
    end
    puts 'Done!'
  end

  desc 'Find sector for each stock in db with csv'
  task find_sector_for_stock_csv: :environment do
    csv_file_path = Rails.root.join('db/nasdaq_screener.csv')
    csv_options = { headers: :first_row, header_converters: :symbol }
    puts 'Loading sectors from csv file...'
    CSV.foreach(csv_file_path, **csv_options) do |row|
      stock_to_update = Stock.find_by(symbol: row[:symbol])
      next if stock_to_update.nil?

      stock_to_update.update(sector: row[:sector])
      puts "#{stock_to_update.symbol} updated"
    end
    puts 'Done!'
  end

  desc 'Find sector for each stock in db with API'
  task find_sector_for_stock_api: :environment do
    puts 'Start!'
    Stock.where(sector: nil).each do |stock|
      ok = Stock.search_profile_info(symbol: stock.symbol)
      if ok
        puts "#{stock.symbol} sector updated"
        sleep 15
      else
        puts "Problems with #{stock.symbol} sector"
      end
    end
    puts 'Done!'
  end
end
