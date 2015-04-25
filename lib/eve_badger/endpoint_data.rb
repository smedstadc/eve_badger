require 'json'

module EveBadger
  module EndpointData
    def self.included(base)
      base.extend(EndpointData)
    end

    module EndpointData
      open(File.join(File.dirname(__FILE__), 'json', 'account_endpoints.json'), 'r') do |file|
        @@account_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end
      open(File.join(File.dirname(__FILE__), 'json', 'character_endpoints.json'), 'r') do |file|
        @@character_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end
      open(File.join(File.dirname(__FILE__), 'json', 'corporation_endpoints.json'), 'r') do |file|
        @@corporation_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end
      open(File.join(File.dirname(__FILE__), 'json', 'detail_endpoints.json'), 'r') do |file|
        @@detail_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end

      def account_endpoint
        @@account_endpoint
      end

      def character_endpoint
        @@character_endpoint
      end

      def corporation_endpoint
        @@corporation_endpoint
      end

      def detail_endpoint
        @@detail_endpoint
      end
    end
  end
end