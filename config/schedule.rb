set :environment, 'development'
set :output, 'log/cron.log'

every :day do
  rake 'stocks:load_stock_info_from_stock_list'
  rake 'stocks:find_sector_for_stock_api'
end
