# frozen_string_literal: true

require 'open-uri'
require 'mini_magick'

# Helper class to create product image params.
# before generating the hash, the following image treatments are performed:
# - resize image
# - remove alpha
# - leaves square
# - convert image to jpg
#
# example;
#
#   params = Magento::Params::CreateImage.new(
#     title: 'Image title',
#     path: '/path/to/image.jpg', # or url
#     position: 1,
#     size: 'small', # options: 'large'(defaut), 'medium' and 'small',
#     disabled: true, # default is false,
#     main: true, # default is false,
#   ).to_h
#
#   Magento::Product.add_media('sku', params)
#
# The resize defaut confiruration is:
#
#   Magento.configure do |config|
#     config.product_image.small_size  = '200x200>'
#     config.product_image.medium_size = '400x400>'
#     config.product_image.large_size  = '800x800>'
#   end
#
module Magento
  module Params

    # Example
    #
    #   Magento::Params::CreateImage.new(
    #     title: 'Some image',
    #     path: '/path/to/image.jpg',
    #     position: 1,
    #     size: 'large', # default large, options medium and small
    #     disabled: false, # default false
    #     main: true # default false
    #   )
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

      # Generates a list containing an Magento::Params::CreateImage
      # instance for each size of the same image.
      #
      # Example:
      #
      #   params = Magento::Params::CreateImage.new(
      #     title: 'Image title',
      #     path: '/path/to/image.jpg', # or url
      #     position: 1,
      #   ).variants
      #
      #   params.map(&:size)
      #   => ['large', 'medium', 'small']
      #
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
        raise "Error on read image #{path}: #{e}"
      end

      def filename
        "#{title.parameterize}-#{VARIANTS[size]}.jpg"
      end

      def mini_type
        file.mime_type
      end
    end
  end
end
