# frozen_string_literal: true

RSpec.describe Diverdown::Helper do
  describe 'ClassMethods' do
    describe '.normalize_module_name' do
      it 'returns string given module' do
        mod = Module.new do
          def self.name
            'X'
          end
        end

        expect(described_class.normalize_module_name(mod)).to eq('X')
      end

      it 'returns string given class' do
        klass = Class.new do
          def self.name
            'X'
          end
        end

        expect(described_class.normalize_module_name(klass)).to eq('X')
        expect(described_class.normalize_module_name(klass.new)).to eq('X')
      end

      it 'returns string given proxied class' do
        klass = Class.new(BasicObject) do
          def method_missing(action, *args)
            ''.public_send(action, *args)
          end

          def respond_to_missing?(action, include_private = false)
            ''.respond_to?(action, include_private)
          end

          def self.name
            'X'
          end
        end

        expect(described_class.normalize_module_name(klass)).to eq('X')
        expect(described_class.normalize_module_name(klass.new)).to eq('X')
      end

      it 'returns nil if argument is anonymous module' do
        mod = Module.new

        expect(described_class.normalize_module_name(mod)).to be_nil
      end

      it 'returns original name if module.name is defined' do
        module A
          def self.name
            raise 'This method should not be called'
          end
        end

        expect(described_class.normalize_module_name(A)).to eq('A')
      ensure
        Object.send(:remove_const, :A)
      end
    end

    describe '.resolve_module' do
      it 'returns string given module' do
        mod = Module.new do
          def self.name
            'X'
          end
        end

        expect(described_class.resolve_module(mod)).to eq(mod)
      end

      it 'returns string given class' do
        klass = Class.new do
          def self.name
            'X'
          end
        end

        expect(described_class.resolve_module(klass)).to eq(klass)
        expect(described_class.resolve_module(klass.new)).to eq(klass)
      end

      it 'returns string given proxy' do
        klass = Class.new(BasicObject) do
          def method_missing(action, *args)
            ''.public_send(action, *args)
          end

          def respond_to_missing?(action, include_private = false)
            ''.respond_to?(action, include_private)
          end

          def self.name
            'X'
          end
        end

        expect(described_class.resolve_module(klass)).to eq(klass)
        expect(described_class.resolve_module(klass.new)).to eq(klass)
      end
    end

    describe '.resolve_singleton_class' do
      it 'returns module' do
        mod = Module.new

        expect(described_class.resolve_singleton_class(mod)).to eq(mod)
      end

      it 'returns class' do
        klass = Class.new

        expect(described_class.resolve_singleton_class(klass)).to eq(klass)
      end

      it 'returns attached object given singleton class' do
        klass = Class.new
        singleton = class << klass; self; end

        expect(described_class.resolve_singleton_class(singleton)).to eq(klass)
      end
    end

    describe '.module?' do
      it 'returns "class" given class' do
        klass = Class.new

        expect(described_class.module?(klass)).to be(true)
      end

      it 'returns "class" given singleton class' do
        klass = Class.new

        expect(described_class.module?(klass.singleton_class)).to be(true)
      end

      it 'returns "instance" given instance' do
        klass = Class.new

        expect(described_class.module?(klass.new)).to be(false)
      end
    end

    describe '.constantize' do
      it 'returns constant given string' do
        expect(described_class.constantize('String')).to eq(String)
      end
    end
  end
end
