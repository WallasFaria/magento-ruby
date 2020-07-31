# frozen_string_literal: true
require 'uri'
require 'http'

module Magento
  class Request
    class << self
      def get(resource)
        salva_requisicao(:get, url(resource))
        tratar_erro http_auth.get(url(resource))
      end

      def put(resource, body)
        salva_requisicao(:put, url(resource), body)
        tratar_erro http_auth.put(url(resource), json: body)
      end

      def post(resource, body = nil, url_completa = false)
        url = url_completa ? resource : url(resource)
        salva_requisicao(:post, url, body)
        tratar_erro http_auth.post(url, json: body)
      end

      private

      def http_auth
        HTTP.auth("Bearer #{Magento.token}")
      end

      def base_url
        url = Magento.url.to_s.sub(%r{/$}, '')
        "#{url}/rest/all/V1"
      end

      def url(resource)
        "#{base_url}/#{resource}"
      end

      def parametros_de_busca(field:, value:, conditionType: :eq)
        criar_parametros(
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

      def parametros_de_campos(campos:)
        criar_parametros(fields: campos)
      end

      def criar_parametros(filter_groups: nil, fields: nil, current_page: 1)
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

      def tratar_erro(resposta)
        unless resposta.status.success?
          begin
            corpo = resposta.parse
          rescue StandardError
            corpo = resposta.to_s
          end
          erro = {
            erro: 'Erro de requisição Magento',
            resposta: { status: resposta.status, corpo: corpo },
            requisicao: @requisicao
          }

          raise Magento::UnprocessedRequestError, erro.to_json
        end

        resposta
      end

      def salva_requisicao(verbo, p_url, p_corpo = nil)
        begin
          corpo = p_corpo[:product].reject { |e| e == :media_gallery_entries }
        rescue StandardError
          corpo = p_corpo
        end

        @requisicao = {
          verbo: verbo,
          url: p_url,
          corpo: corpo
        }
      end
    end
  end
end
