class Output

  attr_accessor :urls, :files, :ip_neighbours, :subdomains, :keywords, :url_keywords, :query_count

  def initialize
    @urls          = []
    @files         = {}
    @ip_neighbours = []
    @subdomains    = {}
    @keywords      = {}
    @url_keywords  = {}
    @query_count   = 0
  end

  def stdout
    puts parsed_urls
    puts
    puts parsed_files
    puts
    puts parsed_ip_neighbours
    puts
    puts parsed_subdomains
    puts
    puts parsed_url_keywords
    puts
    puts parsed_keywords
    puts
    puts "[+] Number of API queries made: #{@query_count}"
    puts
  end

  def parsed_urls
    rows = []

    @urls.uniq.each_with_index do |url,index|
      rows << [index,url]
    end

    Terminal::Table.new :title => "URLs - #{@urls.uniq.size}", :headings => ['Index', 'URL'], :rows => rows
  end

  def parsed_files
    rows = []

    @files.each_with_index do |(file,extention),index|
      rows << [index,file,extention]
    end

    Terminal::Table.new :title => "Files - #{@files.size}", :headings => ['Index', 'File', 'Extension'], :rows => rows
  end

  def parsed_ip_neighbours
    rows = []

    @ip_neighbours.uniq.each_with_index do |domain,index|
      rows << [index,domain]
    end

     Terminal::Table.new :title => "IP Neighbours - #{@ip_neighbours.uniq.size}", :headings => ['Index', 'Domain'], :rows => rows
  end

  def parsed_subdomains
    rows = []
    
    @subdomains.each_with_index do |(domain, ip),index|
      rows << [index, domain, ip]
    end

    Terminal::Table.new :title => "Subdomains - #{@subdomains.size}", :headings => ['Index', 'Domain', 'IP'], :rows => rows
  end

  def parsed_url_keywords
    rows = []

    @url_keywords.each_with_index do |(url, keyword),index|
      rows << [index, url, keyword]
    end

    Terminal::Table.new :title => "URL Keywords - #{@url_keywords.size}", :headings => ['Index', 'URL', 'Keyword'], :rows => rows
  end

  def parsed_keywords
    rows = []

    @keywords.each_with_index do |(url, data),index|
      data.each_pair do |keyword, description|
        rows << [index,url,keyword,description]
      end
    end

    Terminal::Table.new :title => "Page Keywords - #{@keywords.size}", :headings => ['Index', 'URL', 'Keyword', 'Description'], :rows => rows
  end
end