#!/usr/bin/env ruby
require 'mail'


# time in seconds between pop3 email checks
SLEEP_TIME = 60
MESSAGE_FILE_FMT="%H%M%S_%m%d.piazza.txt"


class PiazzaStrings
  def initialize()
    Mail.defaults do
      retriever_method :pop3, :address => "pop.gmail.com",
        :port       => 995,
        :user_name  => ENV['PIAZZA_BOT_USERNAME'],
        :password   => ENV['PIAZZA_BOT_PASSWORD'],
        :enable_ssl => true
    end
  end

  ## !!!!Note: Gmail pop3 settings affect what the script pulls down!!!!
  ## Also, the pop3 all mail setting seems not to stick (only affects first pull)
  ## So keep that in mind when debugging and getting no mail
  def get_mails()
    emails = Mail.find(:what => :first, count: 20, :order => :asc)
    relevant = filter_mails emails
    parse_mails relevant
  end

  private
  def filter_mails(emails)
    emails.select do |mail|
      mail.header['from'].value =~ /1331/ \
        and mail.from.any? {|s| s =~ /piazza\.com$/}
    end
  end

  def parse_mails(emails)
    if emails.empty?
      return []
    else
      return emails.map do |mail|
        # pull out the post between the piazza boilerplate
        match = mail.body.decoded
          .match(/^.*?posted.*?\n{2}(.*?)\n{2}Go to http/m)
        unless match.nil?
          match[1].unpack "M" # this fixes q-encoding artifacts
        else
          nil
        end
      end
    end
  end
end

Thread::abort_on_exception = true

if __FILE__ == $0
  piazza_strings = PiazzaStrings.new

  loop do 
    posts = piazza_strings.get_mails
    break if posts.empty?

    filename = 'piazza.txt'
    puts "Writing #{posts.length} post(s) to #{filename}"
    File.open(filename, 'a') do |file|
      file << posts.join("\n\n\n")
    end
  end
end
