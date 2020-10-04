# frozen_string_literal: true

require 'open-uri'
require 'mini_magick'

module Magento
  module Params
    class CreateImage < Dry::Struct
      VARIANTS = {
        'large'  => :image,
        'medium' => :small_image,
        'small'  => :thumbnail
      }.freeze

      attribute :title,    Type::String
      attribute :path,     Type::String
      attribute :position, Type::Integer
      attribute :size,     Type::String.default('large').enum(*VARIANTS.keys)
      attribute :disabled, Type::Bool.default(false)
      attribute :main,     Type::Bool.default(false)

      def to_h
        {
          "disabled": disabled,
          "media_type": 'image',
          "label": title,
          "position": position,
          "content": {
            "base64_encoded_data": base64,
            "type": mini_type,
            "name": filename
          },
          "types": main ? [VARIANTS[size]] : []
        }
      end

      def variants
        VARIANTS.keys.map do |size|
          CreateImage.new(attributes.merge(size: size, disabled: size != 'large'))
        end
      end

      private

      def base64
        Base64.strict_encode64(File.open(file.path).read).to_s
      end

      def file
        @file ||= MiniMagick::Image.open(path).tap do |b|
          b.resize(Magento.configuration.product_image.send(size + '_size'))
          bigger_side = b.dimensions.max
          b.combine_options do |c|
            c.background '#FFFFFF'
            c.alpha 'remove'
            c.gravity 'center'
            c.extent "#{bigger_side}x#{bigger_side}"
            c.strip
          end
          b.format 'jpg'
        end
      rescue => e
        raise "Erro ao ler imagem #{path}: #{e}"
      end

      def filename
        title.parameterize
      end

      def mini_type
        file.mime_type
      end
    end
  end
end
