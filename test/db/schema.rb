ActiveRecord::Schema.define(:version => 0) do

  create_table "inventory", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wheels", :force => true do |t|
    t.integer  "car_id",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end 

  create_table "wheel_hubs", :force => true do |t|
    t.integer  "inventory_id", :limit => 11
    t.integer  "wheel_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end 

end
