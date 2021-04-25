module ArelHelper
  class DateTimeWithZoneType < ::ActiveRecord::Type::DateTime
    def deserialize(value)
      res = super
      res.in_time_zone(TZ)
    rescue StandardError => e
      res
    end
  end
end
