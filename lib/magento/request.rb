# frozen_string_literal: true

require 'uri'
require 'http'

module Magento
  class Request
    attr_reader :token, :store

    def initialize(token: Magento.token, store: Magento.store)
      @token = token
      @store = store
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
      HTTP.auth("Bearer #{token}")
    end

    def base_url
      url = Magento.url.to_s.sub(%r{/$}, '')
      "#{url}/rest/#{store}/V1"
    end

    def url(resource)
      "#{base_url}/#{resource}"
    end

    def search_params(field:, value:, conditionType: :eq)
      create_params(
        filter_groups: {
          '0': {
            filters: {
              '0': {
                field: field,
                conditionType: conditionType,
                value: value
              }
            }
          }
        }
      )
    end

    def field_params(fields:)
      create_params(fields: fields)
    end

    def create_params(filter_groups: nil, fields: nil, current_page: 1)
      CGI.unescape(
        {
          searchCriteria: {
            currentPage: current_page,
            filterGroups: filter_groups
          }.compact,
          fields: fields
        }.compact.to_query
      )
    end

    def handle_error(resp)
      return resp if resp.status.success?

      begin
        msg = resp.parse['message']
        errors = resp.parse['errors']
      rescue StandardError
        msg = 'Failed access to the magento server'
        errors = []
      end

      raise Magento::NotFound.new(msg, resp.status.code, errors, @request) if resp.status.not_found?

      raise Magento::MagentoError.new(msg, resp.status.code, errors, @request)
    end

    def save_request(method, url, body = nil)
      begin
        body = body[:product].reject { |e| e == :media_gallery_entries }
      rescue StandardError
      end

      @request = { method: method, url: url, body: body }
    end
  end
end
