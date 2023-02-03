require "./spec_helper"

describe RataInmunda do
  it "updates the scrapers correctly" do
    scrapers_file = File.tempfile("scraper") do |file|
      file.print("[\"google.cl\", \"twitter.com\"]")
    end

    first_hash = Digest::SHA256.new.file(scrapers_file.path).final
    scraper_checker = RataInmunda::ScraperChecker.new(scrapers_file.path)

    # Since we haven't changed the file, this shouldn't update anything, and so
    # the function should return false, and the hash should be the same.
    scraper_checker.update_scraper.should be_false
    scraper_checker.current_hash.should eq(first_hash)

    File.open(scrapers_file.path, "w") do |file|
      file.print("[\"google.cl\", \"twitter.com\", \"facebook.com\"]")
    end
    scraper_checker.update_scraper.should be_true
    scraper_checker.current_hash.should_not eq(first_hash)

  ensure
    if scrapers_file
      scrapers_file.delete
    end
  end
end
