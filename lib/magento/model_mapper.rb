module Magento
  module ModelMapper
    def self.to_hash(object)
      hash = {}
      object.instance_variables.each do |attr|
        key   = attr.to_s.delete('@')
        value = object.send(key)
        value = to_hash(value) if value.class.name.include?('Magento::')
        if value.is_a? Array
          value = value.map do |item|
            item.class.name.include?('Magento::') ? to_hash(item) : item
          end
        end
        hash[key] = value
      end
      hash
    end

    def self.map_hash(model, values)
      object = model.new
      values.each do |key, value|
        object.singleton_class.instance_eval { attr_accessor key }
        if value.is_a?(Hash)
          class_name = Magento.inflector.camelize(Magento.inflector.singularize(key))
          value = map_hash(Object.const_get("Magento::#{class_name}"), value)
        elsif value.is_a?(Array)
          value = map_array(key, value)
        end
        object.send("#{key}=", value)
      end
      object
    end

    def self.map_array(key, values)
      result = []
      values.each do |value|
        if value.is_a?(Hash)
          class_name = Magento.inflector.camelize(Magento.inflector.singularize(key))
          result << map_hash(Object.const_get("Magento::#{class_name}"), value)
        else
          result << value
        end
      end
      result
    end
  end

  module ModelParser
    module ClassMethods
      def build(attributes)
        ModelMapper.map_hash(self, attributes)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_h
      ModelMapper.to_hash(self)
    end
  end
end