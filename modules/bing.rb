class Bing
  def initialize(target_domain, pages)
    @api_url       = 'https://api.cognitive.microsoft.com/bing/v7.0/search'
    @api_key       = SpiderConfig.api_key[:bing]
    #@pages         = pages || ModuleHelper.default_pages
    @target_domain = target_domain
    @result_urls   = []
  end

  def all
    #all_pages
    #all_files
    #ip_neighbours
    url_keywords
    #keywords
  end

  def all_pages
    results = request(api_url("site:#{@target_domain}"))

    unless results.empty?
      results['webPages']['value'].each do |result|
        ModuleHelper.output.urls << result['url']
        @result_urls << result['url']
      end
    end

    subdomains_from_results
  end

  def all_files
    ModuleHelper.file_extentions.each do |extention|
      results = request(api_url("site:#{@target_domain} ext:#{extention}"))

      unless results.empty?
        results['webPages']['value'].each do |result|
          ModuleHelper.output.files[result['url']] = extention
          @result_urls << result['url']
        end
      end
    end

    subdomains_from_results
  end

  def url_keywords
    ModuleHelper.url_keywords.each do |keyword|
      results = request(api_url("site:#{@target_domain} instreamset:(url):#{keyword}"))

      p results['webPages']['value']

      unless results.empty? || results['webPages'].nil? || results['webPages']['value'].nil?
        results['webPages']['value'].each do |result|
          unless result['url'].nil?
            p result['url']
            domain        = ModuleHelper.parse_domain(@target_domain).domain
            result_domain = ModuleHelper.parse_domain(result['url']).domain

            p @target_domain, domain, result_domain

            if ModuleHelper.same_domain?(domain, result_domain)
              ModuleHelper.output.url_keywords[result['url']] = keyword
              @result_urls << result['url']
            end
          end
        end
      end
    end

    subdomains_from_results
  end

  def keywords
    ModuleHelper.page_keywords.each do |keyword|
      results = request(api_url("site:#{@target_domain} #{keyword}"))

      unless results.empty?
        results.each do |result|
          ModuleHelper.output.keywords[result['Url']] = { keyword => result['Description'] }
          @result_urls << result['Url']
        end
      end
    end

    subdomains_from_results
  end

  def ip_neighbours
    ip     = ModuleHelper.domain_to_ip(@target_domain)
    domain = PublicSuffix.parse(@target_domain)

    results = request( api_url("ip:#{ip}") )

    unless results.empty?
      results['webPages']['value'].each do |result|
        result_domain = ModuleHelper.parse_domain(result['url']) rescue next

        unless ModuleHelper.same_domain?(domain, result_domain)
          ModuleHelper.output.ip_neighbours << result_domain.to_s
        end
      end
    end

    subdomains_from_results
  end

  def subdomains_from_results
    target_domain = PublicSuffix.parse(@target_domain)

    @result_urls.each do |result|
      result_domain = ModuleHelper.parse_domain(result) rescue next

      if ModuleHelper.subdomain?(target_domain, result_domain)
        ModuleHelper.output.subdomains[result_domain.to_s] = ModuleHelper.domain_to_ip(result_domain.to_s)
      end
    end

    @result_urls.clear
  end

  def request(url)
    sleep 0.5 # Bing API has strict rate limiting
    ModuleHelper.output.query_count += 1
    response = Typhoeus.get(url, headers: { 'Ocp-Apim-Subscription-Key' => @api_key })

    if response.body =~ /The authorization type you provided is not supported/
      puts '[ERROR] Did you put your API key in the api_keys.config file? or is it incorrect?'
      exit
    elsif response.code == 403
      puts '[ERROR] Your Key seems to work but have you subscribed to the "Bing Search API"?'
      exit
    elsif response.body =~ /Insufficient balance for the subscribed offer in user's account/
      puts '[ERROR] You have run out of API queries.'
      exit
    else
      JSON.parse(response.body)
    end
  end

  def api_url(query)
    @api_url + '?q=' + URI.escape(query) + '&responseFilter=Webpages&safeSearch=Off'
  end
end
