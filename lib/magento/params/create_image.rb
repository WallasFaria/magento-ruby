# frozen_string_literal: true

require 'open-uri'
require 'mini_magick'

module Magento
  module Params
    class CreateImage
      VARIANTS = {
        large: { size: '800x800', type: :image },
        medium: { size: '300x300', type: :small_image },
        small: { size: '100x100', type: :thumbnail }
      }

      attr_accessor :path, :title, :position, :size, :disabled, :main

      # @param title: [String]
      # @param position: [Integer]
      # @param path: [String]
      def initialize(title:, position:, path:, size: :large, disabled: false, main: false)
        self.title = title
        self.position = position
        self.path = path
        self.size = size
        self.disabled = disabled
        self.main = main
      end

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
          "types": main ? [VARIANTS[size][:type]] : []
        }
      end

      def variants
        VARIANTS.keys.map do |size|
          clone.tap do |image|
            image.size = size
            image.disabled = size != :large
          end
        end
      end

      private

      def base64
        Base64.strict_encode64(File.open(file.path).read).to_s
      end

      def file
        @file ||= MiniMagick::Image.open(path).tap do |b|
          b.resize VARIANTS[size][:size]
          b.strip
        end
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
