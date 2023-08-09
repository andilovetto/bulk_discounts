class HolidayService

  def self.find_upcoming_holidays
    response = conn.get
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.conn
    Faraday.new(url: "https://date.nager.at/api/v3/NextPublicHolidays/us")
  end

end