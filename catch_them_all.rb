require "mechanize"
require "uri"

class DitcherCatcher
  def initialize(region, start_user, max_depth)
    @region = region
    @matches, @leaves = 0, 0

    @max_depth = max_depth

    @seen  = []
    @users = [start_user]
  end

  def catch_user(user_name)
    agent = Mechanize.new
    url = URI.escape("http://#{@region}.op.gg/summoner/matches/?userName=#{user_name}")
    agent.get(url) do |page|
      leaves  = page.search(".gameResult .leaver").length
      matches = page.search(".gameResult").length

      others  = page.search(".summonerName a").map(&:text)
      unless others.nil? || others.empty?
        @users = @users + others
        @users = @users.uniq! - @seen - [user_name]
      end

      puts "#{leaves} leaves in #{matches} matches for #{user_name}"
      @matches += matches
      @leaves  += leaves
    end
  end

  def catch_em_all
    while @seen.length < @max_depth
      user_name = @users.shuffle!.pop
      @seen << user_name

      catch_user user_name
    end

    puts "Overall #{@matches} matches with #{@leaves} leaves. That's #{format("%02.2f", @leaves / @matches.to_f * 100)}%"
  end
end

if ARGV.length != 3
  puts "Usage: ruby catch_them_all.rb <region> <starting-user> <max-depth>"
  exit
end

region     = ARGV[0]
start_user = ARGV[1]
max_depth  = ARGV[2].to_i

DitcherCatcher.new(region, start_user, max_depth).catch_em_all
