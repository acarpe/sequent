require 'spec_helper'

describe Sequent::Core::Helpers::TypeConversionSupport do
  context String do
    class CommandWithString < Sequent::Core::BaseCommand
      attrs value: String
    end

    it "handles String" do
      command = CommandWithString.new(value: "1")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq "1"
    end

    it "handles nils" do
      command = CommandWithString.new(value: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end
  end

  context Integer do
    class CommandWithInteger < Sequent::Core::BaseCommand
      attrs value: Integer
    end

    it "fails fast when invalid value" do
      command = CommandWithInteger.new(value: "A")
      expect { command.parse_attrs_to_correct_types }.to raise_exception
    end

    it "parses to an Integer" do
      command = CommandWithInteger.new(value: "1")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq 1
    end

    it "handles Integers" do
      command = CommandWithInteger.new(value: 1)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq 1
    end

    it "handles nils" do
      command = CommandWithInteger.new(value: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

    it "handles blank" do
      command = CommandWithInteger.new(value: " ")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

  end

  context Symbol do
    class CommandWithSymbol < Sequent::Core::BaseCommand
      attrs value: Symbol
    end

    it "parses to a Symbol" do
      command = CommandWithSymbol.new(value: "test")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq :test
    end

    it "handles Symbols" do
      command = CommandWithSymbol.new(value: :test)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq :test
    end

    it "handles nils" do
      command = CommandWithSymbol.new(value: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

    it "handles blanks" do
      command = CommandWithSymbol.new(value: " ")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end
  end

  context Boolean do
    class CommandWithBoolean < Sequent::Core::BaseCommand
      attrs value: Boolean
    end

    it "parses to a true" do
      command = CommandWithBoolean.new(value: "true")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq true
    end

    it "parses to a false" do
      command = CommandWithBoolean.new(value: "false")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq false
    end

    it "handles nils" do
      command = CommandWithBoolean.new(value: nil)
      command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

    it "handles true" do
      command = CommandWithBoolean.new(value: true)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq true
    end

    it "handles false" do
      command = CommandWithBoolean.new(value: false)
      command.parse_attrs_to_correct_types
      expect(command.value).to eq false
    end

    it "handles blank" do
      command = CommandWithBoolean.new(value: " ")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end
  end

  context Date do
    class CommandWithDate < Sequent::Core::BaseCommand
      attrs value: Date
    end

    let(:date) { Date.new(2015, 1, 1) }

    it "parses to a Date" do
      command = CommandWithDate.new(value: "01-01-2015")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq date
    end

    it "fails when not a valid Date format" do
      command = CommandWithDate.new(value: "2015-01-01")
      expect { command.parse_attrs_to_correct_types }.to raise_exception
    end

    it "fails when not a valid Date" do
      command = CommandWithDate.new(value: "31-31-2015")
      expect { command.parse_attrs_to_correct_types }.to raise_exception
    end

    it "handles Dates" do
      command = CommandWithDate.new(value: date)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq date
    end

    it "handles nils" do
      command = CommandWithDate.new(value: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

    it "handles blank" do
      command = CommandWithDate.new(value: " ")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end
  end

  context DateTime do
    class CommandWithDateTime < Sequent::Core::BaseCommand
      attrs value: DateTime
    end

    let(:date_time) { DateTime.iso8601("2015-04-06T14:42:32+02:00") }

    it "parses to a DateTime" do
      command = CommandWithDateTime.new(value: "2015-04-06T14:42:32+02:00")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq date_time
    end

    it "fails when not a valid DateTime format" do
      command = CommandWithDateTime.new(value: "06-04-2015T14:42:32+02:00")
      expect { command.parse_attrs_to_correct_types }.to raise_exception
    end

    it "fails when not a valid DateTime" do
      command = CommandWithDateTime.new(value: "SSDFGS345345")
      expect { command.parse_attrs_to_correct_types }.to raise_exception
    end

    it "handles DateTimes" do
      command = CommandWithDateTime.new(value: date_time)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq date_time
    end

    it "handles nils" do
      command = CommandWithDateTime.new(value: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

    it "handles blank" do
      command = CommandWithDateTime.new(value: "")
      command = command.parse_attrs_to_correct_types
      expect(command.value).to be_nil
    end

  end

  context Array do
    class CommandWithArray < Sequent::Core::BaseCommand
      attrs values: array(Integer)
    end

    it "parses an array of Integers" do
      command = CommandWithArray.new(values: ["1"])
      command = command.parse_attrs_to_correct_types
      expect(command.values).to eq [1]
    end

    it "handles an array of Integers" do
      command = CommandWithArray.new(values: [1])
      command = command.parse_attrs_to_correct_types
      expect(command.values).to eq [1]
    end

    it "handles an empty array" do
      command = CommandWithArray.new(values: [])
      command = command.parse_attrs_to_correct_types
      expect(command.values).to eq []
    end

    it "handles nils" do
      command = CommandWithArray.new(values: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.values).to be_nil
    end

    context Sequent::Core::ValueObject do
      class Litmanen < Sequent::Core::BaseCommand
        attrs value: Integer
      end
      class CommandWithArrayWithValueObjects < Sequent::Core::BaseCommand
        attrs values: array(Litmanen)
      end

      it "parses an array of ValueObjects" do
        litmanen = Litmanen.new(value: 1)
        command = CommandWithArrayWithValueObjects.new(values: [litmanen])
        command = command.parse_attrs_to_correct_types
        expect(command.values).to eq [litmanen]
      end

      it "handles nil" do
        command = CommandWithArrayWithValueObjects.new(values: nil)
        command = command.parse_attrs_to_correct_types
        expect(command.values).to be_nil
      end

      it "handles an empty array" do
        command = CommandWithArrayWithValueObjects.new(values: [])
        command = command.parse_attrs_to_correct_types
        expect(command.values).to be_empty
      end
    end

  end

  context "associations" do
    class Nesting < Sequent::Core::ValueObject
      attrs value: Integer
    end

    class CommandWithNesting < Sequent::Core::BaseCommand
      attrs value: Integer, nested: Nesting
    end

    it "parses nested values of commands" do
      command = CommandWithNesting.new(value: "1", nested: Nesting.new(value: "2"))
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq 1
      expect(command.nested.value).to eq 2
    end

    it "handles nils" do
      command = CommandWithNesting.new(value: "1", nested: nil)
      command = command.parse_attrs_to_correct_types
      expect(command.value).to eq 1
      expect(command.nested).to be_nil
    end
  end

end
