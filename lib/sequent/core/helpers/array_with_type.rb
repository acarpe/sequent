module Sequent
  module Core
    module Helpers
      class ArrayWithType
        attr_accessor :item_type

        def initialize(item_type)
          raise "needs a item_type" unless item_type
          @item_type = item_type
        end

        def deserialize_from_json(value)
          value.nil? ? nil : value.map { |item| item_type.deserialize_from_json(item) }
        end

        def to_s
          "Sequent::Core::Helpers::ArrayWithType.new(#{item_type})"
        end
      end
    end
  end
end
