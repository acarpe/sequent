require 'oj'
require_relative 'event_record'

module Sequent
  module Core
    class EventStoreConfiguration
      attr_accessor :record_class, :event_handler_classes

      def initialize(record_class = Sequent::Core::EventRecord, event_handler_classes = [])
        @record_class = record_class
        @event_handler_classes = event_handler_classes
      end
    end

    class EventStore
      class << self
        def configure
          configuration = instance.configuration.dup
          yield(configuration) if block_given?
          @instance = new(configuration) # this makes it threadsafe
        end

        def reset
          @instance = new
        end

        def instance
          @instance ||= new
        end
      end

      attr_accessor :configuration

      def initialize(configuration = EventStoreConfiguration.new)
        self.configuration = configuration
        @record_class = configuration.record_class
        @event_handlers = configuration.event_handler_classes.map(&:new)
      end

      ##
      # Stores the events in the EventStore and publishes the events
      # to the registered event_handlers.
      #
      def commit_events(command, events)
        store_events(command, events)
        publish_events(events, @event_handlers)
      end

      ##
      # Returns all events for the aggregate ordered by sequence_number
      #
      def load_events(aggregate_id)
        event_types = {}
        @record_class.connection.select_all("select event_type, event_json from #{@record_class.table_name} where aggregate_id = '#{aggregate_id}' order by sequence_number asc").map! do |event_hash|
          event_type = event_hash["event_type"]
          event_json = Oj.strict_load(event_hash["event_json"])
          unless event_types.has_key?(event_type)
            event_types[event_type] = Class.const_get(event_type.to_sym)
          end
          event_types[event_type].deserialize_from_json(event_json)
        end
      end

      ##
      # Replays all events in the event store to the registered event_handlers.
      #
      # @param block that returns the event stream.
      def replay_events
        event_stream = yield
        event_types = {}
        event_stream.each do |event_hash|
          event_type = event_hash["event_type"]
          payload = Oj.strict_load(event_hash["event_json"])
          unless event_types.has_key?(event_type)
            event_types[event_type] = Class.const_get(event_type.to_sym)
          end
          event = event_types[event_type].deserialize_from_json(payload)
          @event_handlers.each do |handler|
            handler.handle_message event
          end
        end
      end

      protected
      def record_class
        @record_class
      end

      private

      def publish_events(events, event_handlers)
        events.each do |event|
          event_handlers.each do |handler|
            handler.handle_message event
          end
        end
      end

      def to_events(event_records)
        event_records.map(&:event)
      end

      def store_events(command, events = [])
        command_record = Sequent::Core::CommandRecord.create!(:command => command)
        events.each do |event|
          @record_class.create!(:command_record => command_record, :event => event)
        end
      end
    end
  end
end
