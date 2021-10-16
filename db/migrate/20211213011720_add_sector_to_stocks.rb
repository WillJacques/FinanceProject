class AddSectorToStocks < ActiveRecord::Migration[6.1]
  def change
    add_column :stocks, :sector, :string
  end
end
