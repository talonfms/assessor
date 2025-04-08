module Users
  module TimeZone
    extend ActiveSupport::Concern

    included do
      helper_method :browser_time_zone
    end

    def browser_time_zone
      browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
      ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || ActiveSupport::TimeZone["London"]
    rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
      ActiveSupport::TimeZone["London"]
    end
  end
end
