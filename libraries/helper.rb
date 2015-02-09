require 'net/https'
require 'json'

class Sumologic
  class ApiError < RuntimeError; end

  def self.collector_exists?(node_name, email, pass)
    collector = Sumologic::Collector.new(
      name: node_name,
      api_username: email,
      api_password: pass
    )
    collector.exist?
  end

  class Collector
    attr_reader :name, :api_username, :api_password

    def initialize(opts = {})
      @name = opts[:name]
      @api_username = opts[:api_username]
      @api_password = opts[:api_password]
    end

    def api_endpoint
      'https://api.sumologic.com/api/v1'
    end

    def sources
      @sources ||= fetch_source_data
    end

    def metadata
      collectors['collectors'].find { |c| c['name'] == name }
    end

    def exist?
      !!metadata
    end

    def api_request(options = {})
      uri = options[:uri]
      request = options[:request]
      parse_json = if options.has_key?(:parse_json)
                     options[:parse_json]
                   else
                     true
                   end
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request.basic_auth(api_username, api_password)
      response = http.request(request)
      raise ApiError, "Unable to get source list #{response.inspect}" unless response.is_a?(Net::HTTPSuccess)
      if parse_json
        JSON.parse(response.body)
      else
        response
      end
    end

    def refresh!
      @collectors ||= list_collectors
      @sources = fetch_source_data
      nil
    end

    def list_collectors
      uri = URI.parse(api_endpoint + '/collectors')
      request = Net::HTTP::Get.new(uri.request_uri)
      api_request(uri: uri, request: request)
    end

    def collectors
      @collectors ||= list_collectors
    end

    def id
      metadata['id']
    end

    def fetch_source_data
      u = URI.parse(api_endpoint + "/collectors/#{id}/sources")
      request = Net::HTTP::Get.new(u.request_uri)
      details = api_request(uri: u, request: request)
      details['sources']
    end

    def source_exist?(source_name)
      sources.any? { |c| c['name'] == source_name }
    end

    def source(source_name)
      sources.find { |c| c['name'] == source_name }
    end

    def add_source!(source_data)
      u = URI.parse(api_endpoint + "/collectors/#{id}/sources")
      request = Net::HTTP::Post.new(u.request_uri)
      request.body = JSON.dump({ source: source_data })
      request.content_type = 'application/json'
      response = api_request(uri: u, request: request, parse_json: false)
      response
    end

    def delete_source!(source_id)
      u = URI.parse(api_endpoint + "/collectors/#{source_id}")
      request = Net::HTTP::Delete.new(u.request_uri)
      response = api_request(uri: u, request: request, parse_json: false)
      response
    end

    def update_source!(source_id, source_data)
      u = URI.parse("https://api.sumologic.com/api/v1/collectors/#{id}/sources/#{source_id}")
      request = Net::HTTP::Put.new(u.request_uri)
      request.body = JSON.dump({ source: source_data.merge(id: source_id) })
      request.content_type = 'application/json'
      request['If-Match'] = get_etag(source_id)
      response = api_request(uri: u, request: request, parse_json: false)
      response
    end

    def get_etag(source_id)
      u = URI.parse("https://api.sumologic.com/api/v1/collectors/#{id}/sources/#{source_id}")
      request = Net::HTTP::Get.new(u.request_uri)
      response = api_request(uri: u, request: request, parse_json: false)
      response['etag']
    end
  end
end
