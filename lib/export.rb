class Export
  def self.to_proxy(proxy)
    urls = ModuleHelper.output.urls + ModuleHelper.output.files.map { |url, _file| url }

    urls.uniq.each do |url|
      response = Typhoeus.get(url,
        proxy: proxy,
        ssl_verifypeer: false,
        ssl_verifyhost: 2)

      puts "#{url} [#{response.code}]"
    end
  end
end
