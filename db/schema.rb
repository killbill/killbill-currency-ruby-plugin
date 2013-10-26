require 'active_record'

ActiveRecord::Schema.define(:version => 20130911853636) do
  create_table "currency_updates", :force => true do |t|
    t.string   "base_currency",           :null => false
    t.datetime "conversion_date",         :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index(:currency_updates, :base_currency)

  create_table "currency_rates", :force => true do |t|
    t.string   "target_currency",         :null => false
    t.float   "rate",                    :null => false
    t.integer  "currency_update_id",      :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index(:currency_rates, :currency_update_id)
end



