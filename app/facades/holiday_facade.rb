class HolidayFacade

  def self.get_upcoming_holidays
    holidays = HolidayService.find_upcoming_holidays
    holidays[0..2].map do |holiday|
      Holiday.new(holiday)
    end
  end


end