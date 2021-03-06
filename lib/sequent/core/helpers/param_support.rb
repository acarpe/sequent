require 'active_support'

module Sequent
  module Core
    module Helpers
      # Class to support binding from a params hash like the one from Sinatra
      #
      # You typically do not need to include this module in your classes. If you extend from
      # Sequent::Core::ValueObject, Sequent::Core::Event or Sequent::Core::BaseCommand you will
      # get this functionality for free.
      #
      module ParamSupport
        module ClassMethods
          def from_params(params = {})
            result = allocate
            params = HashWithIndifferentAccess.new(params)
            result.class.types.each do |attribute, type|
              value = params[attribute]

              next if value.blank?
              if type.respond_to? :from_params
                value = type.from_params(value)
              elsif type.is_a? Sequent::Core::Helpers::ArrayWithType
                value = value.map { |v| type.item_type.from_params(v) }
              end
              result.instance_variable_set(:"@#{attribute}", value)
            end
            result
          end

        end
        # extend host class with class methods when we're included
        def self.included(host_class)
          host_class.extend(ClassMethods)
        end

        def to_params(root)
          make_params root, as_params
        end

        def as_params
          hash = HashWithIndifferentAccess.new
          self.class.types.each do |field|
            value = self.instance_variable_get("@#{field[0]}")
            next if field[0] == "errors"
            if value.respond_to?(:as_params) && value.kind_of?(ValueObject)
              value = value.as_params
            elsif value.kind_of?(Array)
              value = value.map { |val| val.kind_of?(ValueObject) ? val.as_params : val }
            elsif value.is_a? DateTime
              value = value.iso8601
            elsif value.is_a? Date
              value = value.strftime("%d-%m-%Y") # TODO Remove to TypeConverter
            end
            hash[field[0]] = value
          end
          hash
        end

        private
        def make_params(root, hash)
          result={}
          hash.each do |k, v|
            key = "#{root}[#{k}]"
            if v.is_a? Hash
              make_params(key, v).each do |k, v|
                result[k] = v.nil? ? "" : v.to_s
              end
            elsif v.is_a? Array
              result[key] = v
            else
              result[key] = v.nil? ? "" : v.to_s
            end
          end
          result
        end
      end
    end
  end
end
