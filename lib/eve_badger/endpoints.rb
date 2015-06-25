require 'json'

module EveBadger
  class Endpoint
    attr_reader :path, :access_mask, :detail_id

    def initialize(data)
      @path = data[:path]
      @access_mask = data[:access_mask]
      @detail_id = data[:detail_id] if data[:detail_id]
    end

    def permitted?(other_mask)
      @access_mask.zero? or (other_mask & @access_mask != 0)
    end
  end

  module Endpoints
    open(File.join(File.dirname(__FILE__), 'json', 'account_endpoints.json'), 'r') do |file|
      @account_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    open(File.join(File.dirname(__FILE__), 'json', 'character_endpoints.json'), 'r') do |file|
      @character_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    open(File.join(File.dirname(__FILE__), 'json', 'corporation_endpoints.json'), 'r') do |file|
      @corporation_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    open(File.join(File.dirname(__FILE__), 'json', 'detail_endpoints.json'), 'r') do |file|
      @detail_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    def self.account(endpoint)
      endpoint_data = @account_endpoints[endpoint]
      unless endpoint_data
        raise "unsupported endpoint: #{endpoint}"
      end
      Endpoint.new(@account_endpoints[endpoint])
    end

    def self.character(endpoint)
      Endpoint.new(@character_endpoints[endpoint])
    end

    def self.corporation(endpoint)
      Endpoint.new(@corporation_endpoints[endpoint])
    end

    def self.detail(endpoint)
      Endpoint.new(@detail_endpoints[endpoint])
    end
  end
end
