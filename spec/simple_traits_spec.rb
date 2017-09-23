require_relative '../lib/trait'
require 'rspec'

describe 'Simple Traits' do

  def def_class(name, trait)
    Object.const_set name.to_sym, Class.new {
      uses trait
      attr_accessor :name

      def initialize(name)
        self.name=name
      end
    }
  end

  before(:each) do
    (Object.send(:remove_const, :T)) rescue Exception
    (Object.send(:remove_const, :A)) rescue Exception

    trait(:T) do
      hello do
        "Hello, my name is #{self.name}"
      end

      method :name, &requirement
    end
  end


  it 'should add the methods to the instance of the classes' do
    def_class(:A, T)

    expect(A.new("John").hello).to eq("Hello, my name is John")
  end

  it 'should leave the methods of the class intact' do
    def_class(:A, T)

    expect(A.new("John").name).to eq("John")
  end

end

