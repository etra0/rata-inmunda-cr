require "http/client"
require "lexbor"
require "digest"
require "json"

module RataInmunda
  # Scraper is in charge of polling the site and returning the corresponding
  # entries.
  class Scraper
    getter url

    def initialize(@url : String)
    end

    def initialize(obj : JSON::PullParser)
      @url = obj.read_string
    end

    def poll : Array(Entry)?
      # Ugly hack for windows, sadly.
      if {{ flag?(:win32) }}
        ssl_context = OpenSSL::SSL::Context::Client.new
        ssl_context.ca_certificates = "C:/Program Files/Common Files/SSL/cacert.pem"
        response = HTTP::Client.get @url, tls: ssl_context
      else
        response = HTTP::Client.get @url
      end

      if response.status_code != 200
        return nil
      end

      parser = Lexbor::Parser.new(response.body)

      entries = [] of Entry
      selector = ".structItem-cell.structItem-cell--main > div.structItem-title a:not(.labelLink)"
      parser.css(selector).each do |entry|
        id = entry.["href"]?.not_nil!.strip("/").split(".")[-1].to_i
        entry = Entry.new(
          entry.inner_text,
          entry.["href"]?.not_nil!,
          id
        )

        entries << entry
      end

      return entries
    end
  end

  # ScraperChecker is the container of all scrapers, w
  class ScraperChecker
    @scrapers = Array(Scraper).new
    @current_hash : Bytes?
    getter current_hash, scrapers

    def initialize(@filename = "scrapers.json")
      self.parse_scrapers
    end

    # This function parses the file and loads the scraper list. It also
    # updates the current hash
    def parse_scrapers
      unless File.exists?(@filename)
        raise Exception.new("Please create the scraper file")
      end

      File.open(@filename) do |file|
        content = file.gets_to_end
        @scrapers = Array(Scraper).from_json(content)
        digest = Digest::SHA256.new
        digest << content
        @current_hash = digest.final
      end
    end

    # This function returns if the file was updated.
    def update_scraper : Bool
      unless File.exists?(@filename)
        raise Exception.new("The scraper file was not found after it was loaded")
      end

      new_hash = Digest::SHA256.new.file(@filename).final
      if new_hash != @current_hash
        puts "File was updated, reparsing..."
        self.parse_scrapers
        return true
      end

      return false
    end
  end
end
