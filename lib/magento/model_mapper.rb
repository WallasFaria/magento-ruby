class ModelMapper
  def initialize(from)
    @from = from
  end

  def to_model(model)
    map_hash(model, @from) if @from
  end

  def to_hash
    self.class.to_hash(@from) if @from
  end

  def self.from_object(object)
    new(object)
  end

  def self.from_hash(values)
    new(values)
  end

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

  private

  def map_hash(model, values)
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

  def map_array(key, values)
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