class URIValidator < ActiveModel::EachValidator

  def validate_each(record, attr, value)
    namespace = options[:namespace]
    raise ArgumentError, "Namespace not found: #{namespace}" unless CONTROLLED_VOCABULARIES.key?(namespace)

    vocabs = options[:in_vocabularies]
    vocabs ||= [options[:in_vocabulary]]
    raise ArgumentError, "#{attr} must specify a vocabulary to validate against!" if vocabs.empty?
    return if value.blank?

    value = [value] unless value.is_a?(Array)

    value.each do |v|
      unless vocabs.any? { |vocab| ::CONTROLLED_VOCABULARIES[namespace][vocab].from_uri(v).present? }
        record.errors.add(attr, :not_recognized)
      end
    end
  end

end
