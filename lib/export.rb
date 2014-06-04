class Export
  def self.to_proxy(proxy)
    LibHelper.all_urls.uniq.each do |url|
      response = Typhoeus.get(url,
        proxy: proxy,
        ssl_verifypeer: false,
        ssl_verifyhost: 2)

      puts "#{url} [#{response.code}]"
    end
  end
end
