class Holiday
  attr_reader :name

  def initialize(data)
    @name = data[:localName]
  end
  
end