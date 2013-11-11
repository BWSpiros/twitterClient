class Status < ActiveRecord::Base

  attr_accessible
  belongs_to(:user,
  class_name: "User",
  foreign_key: :twitter_user_id,
  primary_key: :twitter_user_id
  )

  def self.fetch_statuses_for_user(user_screen_name)
    tweets_uri = Addressable::URI.new(
      :scheme => "http",
      :host => "api.twitter.com",
      :path => "1.1/statuses/user_timeline.json",
      :query_values => {screen_name: user_screen_name}
    )


    tweets_array = JSON.parse(TwitterSession.get(tweets_uri.to_s).body)
  Status.parse_twitter_status(tweets_array )


  end


  def self.parse_twitter_status(all_tweets)
    all_tweets.each do |tweet|
      t = Status.new
      t.twitter_status_id = tweet["id_str"]
      t.twitter_user_id = tweet["user"]["id_str"]
      t.body = tweet['text']
      p t
      if Status.find_by_twitter_status_id(t.twitter_status_id) == nil
        t.save
      else
        next
      end
    end
  end

end
