# UpdatesTimestampOf plugin, an extension for ActiveRecord to easily update
# record timestamps of associated models.
# See ../README for details.
module UpdatesTimestampOf

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def updates_timestamp_of *objects
      before_destroy :update_timestamps
      after_save     :update_timestamps

      class_inheritable_accessor  :skip_update_timestamps
      write_inheritable_attribute :skip_update_timestamps, false

      class_inheritable_reader    :objects_to_update
      write_inheritable_attribute :objects_to_update, objects.map(&:to_s)

      include InstanceMethods
    end
  end

  module InstanceMethods
    # Updates the 'updated_at' or 'updated_on' timestamps of the linked models.
    def update_timestamps
      return if self.skip_update_timestamps

      self.objects_to_update.each do |object_name|
        object = eval "self.#{object_name}"
        next if object.nil?
        [ :updated_at, :updated_on ].each do |field|
          next unless (object.respond_to? field)
          object.send :update_attribute, field, Time.now
          break
        end
      end
    end

    # Code within this block do not trigger timestamp updates to linked models
    def skip_updating_of_linked_timestamps
      self.skip_update_timestamps = true
      yield
      self.skip_update_timestamps = false
    end

    def save_without_updating_linked_timestamps!
      skip_updating_of_linked_timestamps { save! }
    end

    def destroy_without_updating_linked_timestamps
      skip_updating_of_linked_timestamps { destroy }
    end
  end
end
