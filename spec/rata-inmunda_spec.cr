require "./spec_helper"

describe RataInmunda do
  it "checks entries are different" do
    a = RataInmunda::Entry.new("foo", "bar", 1234)
    b = RataInmunda::Entry.new("foo", "bar", 1234)
    c = RataInmunda::Entry.new("foo", "bar", 1235)

    set = Set.new [a, b, c]
    set.size.should eq(2)
  end
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
