class UnsplashFacade
  def self.get_logo
    logo_image = UnsplashService.find_logo
    Image.new(logo_image)
  end

  def self.get_item_image(item_name)
    item_image = UnsplashService.find_item_image(item_name)
    Image.new(item_image[:results].first)
  end

  def self.get_item_image(item_name)
    merchant_image = UnsplashService.find_item_image(item_name)
    Image.new(item_image[:results].first)
  end

  def self.get_random_image
    random_image_url = UnsplashService.find_random_photo
    random_image_url
  end
end