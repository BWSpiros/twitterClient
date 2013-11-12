require 'addressable/uri'
require 'open-uri'
class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name

  has_many(:statuses,
  class_name: "Status",
  foreign_key: :twitter_user_id,
  primary_key: :twitter_user_id
  )

  has_many(:inbound_follows,
  class_name: "Follow",
  foreign_key: :twitter_followee_id,
  primary_key: :twitter_user_id
  )

  has_many(:outbound_follows,
  class_name: "Follow",
  foreign_key: :twitter_follower_id,
  primary_key: :twitter_user_id
  )

  has_many :followed_users, through: :outbound_follows, source: :followee
  has_many :followers, through: :inbound_follows, source: :follower

  def self.use_uri(uri)
    User.parse_twitter_params(JSON.parse(TwitterSession.get(uri.to_s).body))
  end

  def self.fetch_by_screen_name(screenname)
    user_uri = Addressable::URI.new(
      :scheme => "http",
      :host => "api.twitter.com",
      :path => "1.1/users/show.json",
      :query_values => {screen_name: screenname}
    )
    self.use_uri(user_uri)
  end

  def self.fetch_by_id(id)
    user_uri = Addressable::URI.new(
      :scheme => "http",
      :host => "api.twitter.com",
      :path => "1.1/users/show.json",
      :query_values => {user_id: id}
    )
    self.use_uri(user_uri)
  end


  def self.fetch_by_ids(ids)
    user_objects = []
    ids.each do |id|
      if User.find_by_twitter_user_id(id) == nil
        User.fetch_by_id(id)
      end
      user_objects << User.find_by_twitter_user_id(id)
    end
    user_objects
  end

  def self.parse_twitter_params(params)
    p params["id_str"]
    p params["screen_name"]
    u = User.new(
    twitter_user_id: params["id_str"],
    screen_name: params["screen_name"]
    )
    return nil if params["id_str"] == nil || params["screen_name"] == nil
    if User.find_by_twitter_user_id(u.twitter_user_id) == nil
      u.save!
      p "SAVED!"
    end
  end


  def self.fetch_followers(user_id)
    followers_uri = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/followers/ids.json",
      :query_values => {user_id: user_id, stringify_ids: true}
    )
    followers = JSON.parse(TwitterSession.get(followers_uri.to_s).body)['ids']
    p "GOT THIS FAR"
    puts followers.size
    sync_followers(followers, user_id)
  end


  def self.sync_followers(followers, followed_person)
    followed = User.find_by_twitter_user_id(followed_person)
    followers.each do |follower|
      if (!User.find_by_twitter_user_id(follower).nil?) && (followed.followers.include? follower)
        next
      end
      next if Follow.find_by_twitter_follower_id_and_twitter_followee_id(follower, followed_person )
      f_obj = fetch_by_id(follower)
      f = Follow.new
      f.twitter_follower_id = follower
      f.twitter_followee_id = followed_person
      f.save
    end
  end

  def self.sync_statuses(username)
    Status.fetch_statuses_for_user(username)
  end
end
