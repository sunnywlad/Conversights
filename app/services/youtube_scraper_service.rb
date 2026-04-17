require 'google/apis/youtube_v3'

class YoutubeScraperService
  def initialize(name:, brand:, query: nil)
    @youtube_service = Google::Apis::YoutubeV3::YouTubeService.new
    @youtube_service.key = ENV['YOUTUBE_API_KEY']
    @name = name
    @query = query ? "#{query} #{name} #{brand}" : "#{name} #{brand}"
  end

  def call(max_videos = 3, page_token: nil)
    video_ids, next_page_token = fetch_video_ids(max_videos, page_token)

    comments = video_ids.flat_map { |video_id| fetch_comments(video_id) }.compact
    [comments, next_page_token]
  end

  private

  def fetch_video_ids(limit, page_token = nil)
    response = @youtube_service.list_searches(
      'id,snippet',
      q: @query,
      type: 'video',
      max_results: limit,
      page_token: page_token
    )
    video_ids = response.items.filter_map do |item|
      if item.snippet.title.downcase.include?(@name.downcase) || item.snippet.description.to_s.downcase.include?(@name.downcase)
        item.id.video_id
      end
    end
    [video_ids, response.next_page_token]
  end

  def fetch_comments(video_id)
    begin
      response = @youtube_service.list_comment_threads(
        'snippet',
        video_id: video_id,
        max_results: 15,
        order: 'relevance'
      )
      response.items.map do |item|
        raw_text = item.snippet.top_level_comment.snippet.text_original
        clean_comment(raw_text)
      end.compact_blank.select { |text| useful_comment?(text) }
    rescue Google::Apis::ClientError => e
      puts "Error fetching comments for video #{video_id}: #{e.message}"
      []
    end
  end

  private

  def clean_comment(text)
    return nil if text.nil? || text.empty?

    text = text.downcase
    # 1. Supprimer les balises HTML (<br>, <b>, etc.)
    text = text.gsub(/<[^>]*>/, " ")
    # 2. Supprimer les URLs (inutiles pour l'analyse de sentiment)
    text = text.gsub(/https?:\/\/\S+/, "")
    # 3. Supprimer les caractères spéciaux inutiles et emojis complexes
    # On garde lettres, chiffres et ponctuation de base
    text = text.gsub(/[^a-z0-9àâçéèêëîïôûù\s\d.,!?'"]/, "")
    # 4. Nettoyer les espaces multiples et sauts de ligne
    text.squish
  end

  def useful_comment?(text)
    return false if text.nil?
    words = text.split(/\s+/)
    words.size > 5 && words.size < 450
  end

end
