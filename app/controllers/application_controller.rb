class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  class Entry
    def initialize(title, image)
      @title = title
      @image = image
    end
    attr_reader :title
    attr_reader :image
  end

  def scrape_imcdbx
    require 'open-uri'
    doc = Nokogiri::HTML(open("http://www.imcdb.org/makes.php"))

    entries = doc.css('.BoxContents li')
    @entriesArray = []
    entries.each do |entry|
      title = entry.css('a').text
      link = entry.css('a')[0]['href']
      @entriesArray << Entry.new(title, link)
    end
    render template: 'scrape_imcdb'
  end

  def scrape_imcdb
    if params[:make] && params[:model]
      require 'open-uri'
      doc = Nokogiri::HTML(open("http://www.imcdb.org/vehicles.php?make=#{params[:make]}&model=#{params[:model]}"))
  
      entries = doc.css('.ThumbnailBox.WithTitle')
      @entriesArray = []
      entries.each do |entry|
        title = entry.css('a')[3].text
        image = 'http://www.imcdb.org/'+entry.css('.Thumbnail img').map{ |i| i['src'] }.join
        @entriesArray << Entry.new(title, image)
      end
      render template: 'scrape_imcdb'
    else 
      render template: 'scrape_search'
    end
  end

end
