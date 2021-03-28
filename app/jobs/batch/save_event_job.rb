class Batch::SaveEventJob < ApplicationJob
  queue_as :default

  REQUEST_BASE_URL = "https://connpass.com/api/v1/event/".freeze
  YOUTUBE_LIVE_KEYWORD = "youtu.be".freeze
  GET_COUNT = 100
  REQUEST_URL_BY_YOUTUBE = "#{REQUEST_BASE_URL}?keyword=#{YOUTUBE_LIVE_KEYWORD}&count=#{GET_COUNT}".freeze
  SEARCH_START_DATE = Date.new(2012, 0o1, 0o1)
  SEARCH_DATE_ARRAY = (SEARCH_START_DATE..Date.current).map(&:beginning_of_month).uniq

  def perform(_args = {})
    SEARCH_DATE_ARRAY.each do |date|
      ym_query = fix_format_date_to_ymquery(date)
      api_url = "#{REQUEST_URL_BY_YOUTUBE}&ym=#{ym_query}"
      response = get_response_body(api_url)
      next if response.blank?

      fixed_response = JSON.parse(response)
      next unless exist_response_data?(fixed_response)

      fixed_response["events"].each do |connpass_event|
        event = Event.find_or_initialize_by(connpass_event_id: connpass_event["event_id"])
        formated_params = format_event_to_params(connpass_event)
        begin
          event.update!(formated_params)
        rescue StandardError => e
          Rails.logger.error(e.message)
          Raven.capture_exception(e) if Rails.env.production?
        end
      end
      sleep 1
    end
  end

  private

  def fix_format_date_to_ymquery(date)
    date.year.to_s + format("%02d", date.month)
  end

  def get_response_body(api_url)
    url = URI.parse(api_url)
    response = Net::HTTP.get_response(url)
    response.body.presence || ""
  end

  def exist_response_data?(response)
    response["results_returned"].to_i.positive?
  end

  def format_event_to_params(event)
    {
      title: event["title"] || "",
      catch: event["catch"] || "",
      description: event["description"] || "",
      connpass_event_url: event["event_url"],
      hash_tag: event["hash_tag"] || "",
      started_at: event["started_at"].to_datetime,
      ended_at: event["ended_at"].to_datetime,
      limit: event["limit"].to_i,
      event_type: event["event_type"],
      address: event["address"] || "",
      place: event["place"] || "",
      lat: event["lat"].present? ? event["lat"].to_i : nil,
      lon: event["lon"].present? ? event["lon"].to_i : nil,
      accepted: event["accepted"].to_i,
      waiting: event["waiting"].to_i,
      applicant: event["waiting"].to_i + event["accepted"].to_i,
      connpass_event_id: event["event_id"].to_i,
      connpass_updated_at: event["updated_at"].to_datetime
    }
  end
end
