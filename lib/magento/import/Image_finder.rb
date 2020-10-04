module Magento
  module Import
    class ImageFinder
      EXTENTIONS = %w[jpg jpeg png webp gif].freeze

      def initialize(images_folder)
        @images_folder = images_folder
      end

      def find_by_name(name)
        prefix = "#{@images_folder}/#{name}"

        EXTENTIONS.map { |e| ["#{prefix}.#{e}", "#{prefix}.#{e.upcase}"] }.flatten
                  .find { |file| File.exist?(file) }
      end
    end
  end
end
