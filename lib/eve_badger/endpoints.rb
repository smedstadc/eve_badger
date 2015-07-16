require 'json'

module EveBadger
  class Endpoint
    attr_reader :path, :access_mask, :detail_id

    # initialize with :path, :access_mask and optionally :detail_id
    def initialize(data)
      @path = data[:path]
      @access_mask = data[:access_mask]
      @detail_id = data[:detail_id] if data[:detail_id]
    end

    # test whether a given api key bitmask is sufficient to make a request against this endpoint
    def permitted?(other_mask)
      @access_mask.zero? or (other_mask & @access_mask != 0)
    end
  end

  # loads endpoint data from JSON files packaged with the gem, these JSON files are easily edited if API endpoints are added or changed in the future
  module Endpoints
    # load account endpoint data
    open(File.join(File.dirname(__FILE__), 'json', 'account_endpoints.json'), 'r') do |file|
      @account_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    # load character endpoint data
    open(File.join(File.dirname(__FILE__), 'json', 'character_endpoints.json'), 'r') do |file|
      @character_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    # load corporation endpoint data
    open(File.join(File.dirname(__FILE__), 'json', 'corporation_endpoints.json'), 'r') do |file|
      @corporation_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    # load detail endpoint data
    open(File.join(File.dirname(__FILE__), 'json', 'detail_endpoints.json'), 'r') do |file|
      @detail_endpoints = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    # takes an account endpoint name and returns an endpoint data object
    def self.account(endpoint)
      data = @account_endpoints[endpoint]
      raise ArgumentError, "unsupported endpoint: #{endpoint}" unless data
      Endpoint.new(data)
    end

    # takes a character endpoint name and returns an endpoint data object
    def self.character(endpoint)
      data = @character_endpoints[endpoint]
      raise ArgumentError, "unsupported endpoint: #{endpoint}" unless data
      Endpoint.new(data)
    end

    # takes a corporation endpoint name and returns an endpoint data object
    def self.corporation(endpoint)
      data = @corporation_endpoints[endpoint]
      raise ArgumentError, "unsupported endpoint: #{endpoint}" unless data
      Endpoint.new(data)
    end

    # takes a detail endpoint name and returns an endpoint data object
    def self.detail(endpoint)
      data = @detail_endpoints[endpoint]
      raise ArgumentError, "unsupported endpoint: #{endpoint}" unless data
      Endpoint.new(data)
    end
  end
end
