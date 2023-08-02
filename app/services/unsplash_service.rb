class UnsplashService

  def self.find_logo
    response = conn('/photos/kOGDVpRl3RE').get do |faraday|
      faraday.params['client_id'] = "kpMMx2904Yk5kq69M6reYJQP1xkiTIaVegKTk1ojh8g"
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.find_item_image(item_name)
    response = conn("/search/photos").get do |faraday|
      faraday.params['client_id'] = "kpMMx2904Yk5kq69M6reYJQP1xkiTIaVegKTk1ojh8g" #UNSPLASH_ACCESS_KEY stored as env variable in figaro generated yml file
      faraday.params['query'] = item_name
      # faraday.params['per_page'] = '1'
      # faraday.params['page'] = '1' #tried to limit results but these query params did not work tried with both strings and ints
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.conn(endpoint_url)
    url = "https://api.unsplash.com#{endpoint_url}"
    Faraday.new(url: url)
  end
end