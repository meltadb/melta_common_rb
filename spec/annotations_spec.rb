require 'rspec'
require_relative '../lib/interceptor'

describe 'Annotations' do

  context 'Test simple interceptor' do

    class AnotherResult < Interceptor
      def initialize(a_value)
        @value = a_value
      end

      def call(method, *args, &block)
        @value
      end
    end

    class AnotherResultNoArgs < Interceptor

      def call(method, *args, &block)
        23424
      end
    end

    after(:each) do
      Object.send :remove_const, :A if Kernel.const_defined? :A
    end

    it 'Should replace value and ignore current method return' do
      class A
        extend Interceptions

        AnotherResult.new(42).before_method
        def bleh()
          2
        end
      end

      a = A.new
      expect(a.bleh).to eq 42
    end

    it 'llamar a un Interceptor desde la clase' do
      valor = 23424
      class A
        extend Interceptions

        AnotherResultNoArgs.before_method
        def bleh()
          2
        end
      end

      a = A.new
      expect(a.bleh).to eq valor
    end

    it 'Llamar desde el modulo directamente' do
      valor = 23424

      class A
        extend Interceptions

        before_method AnotherResultNoArgs
        def bleh()
          2
        end
      end

      a = A.new
      expect(a.bleh).to eq valor

    end

    it 'Llamar desde una instancia en vez de una clase' do
      class A
        extend Interceptions

        before_method AnotherResult.new(42)
        def bleh()
          2
        end
      end

      a = A.new
      expect(a.bleh).to eq 42
    end

  end

end