require 'httparty'

module Tvdb
  class Client
    include HTTParty
    format :json
    # base_uri 'localhost:8080'
    base_uri 'https://api.thetvdb.com'
    # cache_api_responses key_name: 'tvdb', expire_in: 3600

    def initialize(user, id, key, options = {})
      @user = user
      @id = id
      @key = key
      @options = {
          lang: 'en',
          debug: false
      }.merge(options)
      @lang = @options[:lang]

      self.class.headers 'Content-type' => 'application/json'
      @token = auth()
      self.class.headers 'Authorization' => 'Bearer ' + @token
    end

    def authenticated?
      @token != ''
    end

    def search(name)
      self.class.get('/search/series', query: {name: name}).parsed_response
    end

    def series_find(id)
      get("/series/#{id}")
    end

    def series_episodes(id)
      get("/series/#{id}/episodes")
    end

    def series_images(id)
      fanart = get("/series/#{id}/images/query", {keyType: 'fanart', single: true})
      poster = get("/series/#{id}/images/query", {keyType: 'poster', single: true})
      {fanart: fanart, poster: poster}
    end

    def series_images_params(id)
      get("/series/#{id}/images/query/params")
    end

    def episode_find(id)
      get("/episodes/#{id}")
    end

    def updated_since(unixtime)
      get("/updated/query", {fromTime: unixtime})
    end

    private

    def auth
      # use this if we need to talk to /user urls to manager user-specific stuff
      # response = self.class.post('/login', query: {apikey: @key, userkey: @id, username: @user}).parsed_response
      response = self.class.post('/login', body: {apikey: @key}.to_json).parsed_response

      unless response['token']
        raise "could not authenticate: #{response.inspect}"
      end

      response['token']
    end

    def get(path, params={})
      single = params.delete(:single)
      if single
        r = _request(path, params)
        (r['data'] && [r['data']].flatten || r)
      else
        _pages(path, params)
      end
    end

    def _pages(path, params)
      total = 1
      page = 1
      out = []

      while page <= total do
        if @options[:debug]
          puts "request:  #{page}/#{total}"
        end

        r = _request(path, params.merge({page: page}))

        if r['links'] && r['links']['last']
          total = r['links']['last']
        end

        if r['errors'] || r['Error']
          raise "errors in '#{path}' request: #{(r['errors']||r['Error']).inspect}"
        end

        out += (r['data'] && [r['data']].flatten || r)
        page += 1
      end

      out
    end

    def _request(path, params)
      r = self.class.get(path, query: params).parsed_response

      if @options[:debug]
        puts "response: #{r}"
      end

      r
    end
  end
end
