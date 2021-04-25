class AddPaymentTable < ActiveRecord::Migration[5.2]
  def up
    return if table_exists? :payments
    create_table :payments do |t|
      t.text :payer
      t.timestamp :paid_at
      t.decimal :amount, default: 0.0, precision: 23, scale: 4
      t.string :item
      t.timestamps
    end
  end

  def down
    drop_table :payments if table_exists? :payments
  end
end
