require File.dirname(__FILE__) + '/../test/test_helper' 

# ---------------------------------------------------------
# Test models.
# ---------------------------------------------------------

class Inventory < ActiveRecord::Base
  self.table_name = 'inventory'
end

class Car < ActiveRecord::Base
end

class Wheel < ActiveRecord::Base
  belongs_to :car
  updates_timestamp_of :car
end

class WheelHub < ActiveRecord::Base
  belongs_to :wheel
  belongs_to :inventory
  updates_timestamp_of :wheel, :inventory
end


# ---------------------------------------------------------
# Test cases.
# ---------------------------------------------------------

class UpdatesTimestampOfTest < Test::Unit::TestCase


  def setup
    @inventory  =  Inventory.create!
    @car        =        Car.create!
    @wheel      =      Wheel.create! :car   => @car
    @wheel_hub  =   WheelHub.create! :wheel => @wheel, :inventory => @inventory
    @inventory2 = @inventory.clone 
    @car2       =       @car.clone
    @wheel2     =     @wheel.clone 
    reset_timestamps
  end

  def teardown
    [ Inventory, Car, Wheel, WheelHub ].map(&:delete_all)
  end

  def test_cloning
    assert_clones
  end

  def show obj
    puts obj.updated_at.to_i
  end

  def test_saving
    touch @wheel
    @wheel.save!
    assert_timestamp :not_equal, @wheel, @wheel2
    assert_timestamp :not_equal, @car  , @car2
    assert_timestamp :equal,     @wheel, @car

    reset_timestamps
    touch @wheel
    @wheel.save_without_updating_linked_timestamps!
    assert_timestamp :not_equal, @wheel, @car

    reset_timestamps
    @wheel.skip_updating_of_linked_timestamps do
      touch @wheel
      @wheel.save!
      assert_timestamp :not_equal, @wheel, @car
    end
  end

  def test_advanced_saving
    @wheel_hub.created_at = Time.now
    @wheel_hub.save!
    assert_basic :equal 

    reset_timestamps 
    @wheel_hub.created_at = Time.now
    @wheel_hub.save_without_updating_linked_timestamps!
    assert_basic :equal 

    reset_timestamps 
    @wheel_hub.skip_updating_of_linked_timestamps do
      @wheel_hub.created_at = Time.now
      @wheel_hub.save!
      assert_basic :equal 
    end
  end

  def test_destroy
    @wheel.destroy
    assert_timestamp :not_equal, @car, @car2
  end

  def test_destroy_without_updating
    @wheel.destroy_without_updating_linked_timestamps
    assert_timestamp :equal, @car, @car2
  end

  def test_destroy_skip_updating
    @wheel.skip_updating_of_linked_timestamps do
      @wheel.destroy
      assert_timestamp :equal, @car, @car2
    end
  end

  def test_advanced_destroy
    assert_advanced(:not_equal) do
      @wheel_hub.destroy
    end
  end

  def test_advanced_destroy_without_updating
    assert_advanced(:equal) do
      @wheel_hub.destroy_without_updating_linked_timestamps
    end
  end

  def test_advanced_destroy_skip_updating
    assert_advanced(:equal) do
      @wheel_hub.skip_updating_of_linked_timestamps do
        @wheel_hub.destroy
      end
    end
  end


  private

  # Reset the timestamps to be all the same, to some value back in time.
  def reset_timestamps
    time = Time.now - 1000 
    # Note that the order of the objects is important here!
    [ @wheel_hub, @wheel , @car , @inventory , 
                  @wheel2, @car2, @inventory2 ].each do |obj|
      obj.class.record_timestamps = false
      obj.update_attributes! :created_at => time, :updated_at => time
      obj.class.record_timestamps = true 
    end
  end

  def assert_basic atype=:equal
    assert_timestamp atype, @wheel_hub, @wheel
    assert_timestamp atype, @wheel_hub, @car
    assert_timestamp atype, @wheel_hub, @inventory
  end

  def assert_advanced atype=:equal
    assert_basic :equal 
    yield
    assert_basic  atype
    assert_clones atype 
  end

  def assert_clones atype=:equal
    assert_timestamp atype, @inventory, @inventory2
    assert_timestamp atype, @wheel    , @wheel2
    assert_timestamp atype, @car      , @car2
  end

  # Allow 1 sec difference to be considered equal. Otherwise tests may randomly
  # fail.
  def assert_timestamp atype, obj1, obj2
    ts1 = obj1.updated_at.to_i
    ts2 = obj2.updated_at.to_i
    if atype == :equal
      if ts1 == ts2
        assert_equal ts1, ts2
      elsif (ts1-ts2).abs == 1
        assert_equal ts1, ts1   # always true for constant stats
      end
    else
      assert_not_equal ts1, ts2
    end
  end

  # 'Touch' the object by modifying its created_at timestamp.
  def touch obj
    obj.created_at = Time.now
  end

end

