class CreatePortfolios < ActiveRecord::Migration[6.1]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end

    add_index :portfolios, :user_id
  end
end
