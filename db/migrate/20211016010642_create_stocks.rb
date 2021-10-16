class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.text :stock_info, limit: 4_294_967_295
      t.date :last_call_to_api
      t.string :company_name

      t.timestamps
    end
  end
end
