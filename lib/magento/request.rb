# frozen_string_literal: true

require 'uri'
require 'http'

module Magento
  class Request
    attr_reader :config

    def initialize(config: Magento.configuration)
      @config = config
    end

    def get(resource)
      save_request(:get, url(resource))
      handle_error http_auth.get(url(resource))
    end

    def put(resource, body)
      save_request(:put, url(resource), body)
      handle_error http_auth.put(url(resource), json: body)
    end

    def post(resource, body = nil, url_completa = false)
      url = url_completa ? resource : url(resource)
      save_request(:post, url, body)
      handle_error http_auth.post(url, json: body)
    end

    def delete(resource)
      save_request(:delete, url(resource))
      handle_error http_auth.delete(url(resource))
    end

    private

    def http_auth
      HTTP.auth("Bearer #{config.token}")
          .timeout(connect: config.timeout, read: config.open_timeout)
    end

    def base_url
      url = config.url.to_s.sub(%r{/$}, '')
      "#{url}/rest/#{config.store}/V1"
    end

    def url(resource)
      "#{base_url}/#{resource}"
    end

    def handle_error(resp)
      return resp if resp.status.success?

      begin
        msg = resp.parse['message']
        errors = resp.parse['errors'] || resp.parse['parameters']
        resp.parse['parameters'].each { |k, v| msg.sub! "%#{k}", v } if resp.parse['parameters'].is_a? Hash
      rescue StandardError
        msg = 'Failed access to the magento server'
        errors = []
      end

      raise Magento::NotFound.new(msg, resp.status.code, errors, @request) if resp.status.not_found?

      raise Magento::MagentoError.new(msg, resp.status.code, errors, @request)
    end

    def save_request(method, url, body = nil)
      begin
        body = body.symbolize_keys[:product].reject { |e| e == :media_gallery_entries }
      rescue StandardError
      end

      @request = { method: method, url: url, body: body }
    end
  end
end
