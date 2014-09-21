class Music
  PROPERTIES = [:provider, :track_id, :track_name, :artist_name, :collection_name, :track_view_url, :artwork_url]
  PROPERTIES.each do |prop|
    attr_accessor prop
  end

  MEDIA = 'music'
  ENTITY = 'song'
  ATTRIBUTE = 'songTerm'
  LIMIT = 20

  SC_CLIENT_ID = '3c09787de44c7532d1e9951e4e10aae2'

  @itunes_client = AFMotion::SessionClient.build('http://itunes.apple.com/') do
    session_configuration :default
    header "Accept", "application/json"
    response_serializer :json
  end

  @soundcloud_client = AFMotion::SessionClient.build('https://api.soundcloud.com/') do
    session_configuration :default
    header "Accept", "application/json"
    response_serializer :json
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value) if PROPERTIES.member?(key.to_sym)
    end
  end

  def self.search_from_itunes(params, &callback)
    params.merge!(
      media: MEDIA,
      entity: ENTITY,
      attribute: ATTRIBUTE,
      limit: LIMIT
    )

    params[:term] = params[:term].gsub(/(\s|　)+/, '+')

    @itunes_client.get('search', params) do |result|
      if result.success? && result.object.present?
        musics = []
        result.object['results'].each do |data|
          music = Music.new(
            provider: 'itunes',
            track_id: data['trackId'],
            track_name: data['trackName'],
            artist_name: data['artistName'],
            collection_name: data['collectionName'],
            track_view_url: data['trackViewUrl'],
            artwork_url: data['artworkUrl100']
          )
          musics << music
        end
        callback.call(musics, nil)
      elsif result.failure?
        callback.call([], result.error)
      end
    end
  end

  def self.search_from_soundcloud(params, &callback)
    params.merge!(
      client_id: SC_CLIENT_ID,
      limit: LIMIT
    )

    @soundcloud_client.get('tracks', params) do |result|
      if result.success? && result.object.present?
        musics = []
        result.object.each do |data|
          music = Music.new(
            provider: 'soundcloud',
            track_id: data['id'],
            track_name: data['title'],
            artist_name: data['user']['username'],
            collection_name: 'from SoundCloud',
            track_view_url: data['permalink_url'],
            artwork_url: data['artwork_url'] || data['user']['avatar_url']
          )
          musics << music
        end
        callback.call(musics, nil)
      elsif result.failure?
        callback.call([], result.error)
      end
    end
  end

end
