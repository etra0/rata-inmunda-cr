require "tourmaline"
require "dotenv"
require "./rata-inmunda/*"

# TODO: Write documentation for `Rata::Inmunda::Reborn::V3`
module RataInmunda
  VERSION = "0.1.0"

  class RataInmunda < Tourmaline::Client
    @[Command("echo")]
    def echo_command(ctx)
      ctx.message.reply(ctx.text)
    end
  end

  # env = Dotenv.load ".env"
  # bot = RataInmunda.new(bot_token: env["BOT_TOKEN"])
  # puts("Starting bot...")
  # bot.poll
  # some_entry = Entries::Entry.new("foo", "bar", 123)
  # puts some_entry.to_s
  # scraper = Scraper.new("google.cl")
  # output = scraper.poll.not_nil!
  # puts output.map(&.to_s)
end
