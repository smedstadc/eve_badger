require 'yaml'

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
    @account_endpoints = YAML.load_file(File.join(File.dirname(__FILE__), 'yaml', 'account_endpoints.yml'))

    # load character endpoint data
    @character_endpoints = YAML.load_file(File.join(File.dirname(__FILE__), 'yaml', 'character_endpoints.yml'))

    # load corporation endpoint data
    @corporation_endpoints = YAML.load_file(File.join(File.dirname(__FILE__), 'yaml', 'corporation_endpoints.yml'))

    # load detail endpoint data
    @detail_endpoints = YAML.load_file(File.join(File.dirname(__FILE__), 'yaml', 'detail_endpoints.yml'))

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
