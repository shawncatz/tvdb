require "spec_helper"

RSpec.describe Tvdb do
  it "has a version number" do
    expect(Tvdb::VERSION).not_to be nil
  end

  describe Tvdb::Client do
    before(:all) do
      @client = Tvdb::Client.new(CFG['username'], CFG['userkey'], CFG['apikey'], debug: CFG['debug'] == 'true')
    end
    it "can authenticate" do
      expect(@client.authenticated?).to be true
    end

    it "can search" do
      expect { @client.search('the walking dead') }.not_to raise_error
    end

    it 'can find a series' do
      expect(@client.series_find(CFG['series'])).not_to be nil
    end

    it 'can find episodes for a series' do
      expect(@client.series_episodes(CFG['series'])).not_to be nil
    end

    it 'can find images for a series' do
      expect(@client.series_images(CFG['series'])).not_to be nil
    end

    it 'can find images params for a series' do
      expect(@client.series_images_params(CFG['series'])).not_to be nil
    end

    it 'can find an episode' do
      expect(@client.episode_find(CFG['episode'])).not_to be nil
    end

    it 'can get updated series since yesterday' do
      expect(@client.updated_since(Time.now.to_i-(24 * 60 * 60))).not_to be nil
    end
  end
end
