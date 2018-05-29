class ModuleHelper
  def self.default_pages
    10
  end

  # Original list from FuzzDB.
  def self.file_extentions
    File.open('data/file_extentions.txt').read.split("\n")
  end

  def self.page_keywords
    File.open('data/page_keywords.txt').read.split("\n")
  end

  def self.url_keywords
    File.open('data/url_keywords.txt').read.split("\n")
  end

  def self.domain_to_ip(domain)
    IPSocket.getaddress(domain) rescue ''
  end

  def self.output
    @output ||= Output.new
  end

  def self.same_domain?(target, result)
    return false if result.nil?
    target.domain === result.domain
  end

  def self.subdomain?(target, result)
    if result.subdomain
      target.domain == result.domain && target.subdomain != result.subdomain
    end
  end

  def self.parse_domain(domain)
    domain = URI(domain).host
    PublicSuffix.parse(domain) if PublicSuffix.valid?(domain)
  end
end
