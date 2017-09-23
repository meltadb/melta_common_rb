require_relative '../lib/trait'
require 'rspec'


describe 'My behaviour' do

  before(:each) do
    (Object.send(:remove_const, :T)) rescue Exception
    (Object.send(:remove_const, :A)) rescue Exception

    trait(:T) do
      hello do
        "Hello, my name is #{self.name}"
      end

      method :name, &requirement
    end

    class AClass
      uses T
      attr_accessor :name

      def initialize(name)
        self.name=name
      end
    end
  end

  it 'should do something' do
    a_class_instance = AClass.new('Tom')
    expect(a_class_instance.hello).to eq('Hello, my name is Tom')
  end
end