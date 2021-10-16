class CreateStockPortfolioUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :stock_portfolio_users do |t|
      t.references :user, index: true, null: false, type: :integer, foreign_key: true
      t.references :stock, index: true, null: false, type: :integer, foreign_key: true
      t.references :portfolio, index: true, null: false, type: :integer, foreign_key: true
      t.index %i[user_id stock_id portfolio_id], name: :uniq_index_on_user_and_stock_and_portfolio
      t.decimal :stock_value, precision: 10, scale: 6
      t.decimal :stock_quantity, precision: 10, scale: 6

      t.timestamps
    end
  end
end
