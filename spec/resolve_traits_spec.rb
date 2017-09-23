require 'rspec'
require_relative '../lib/trait'

describe 'Trait resolve tests' do

  before(:each) do
    (Object.send(:remove_const, :T1)) rescue Exception
    (Object.send(:remove_const, :T2)) rescue Exception

    trait(:T1) do
      m1 do |argument|
        "t1.m1"
      end
    end

    trait(:T2) do
      m1 do |argument|
        "t2.m1"
      end
    end

    trait(:T4) do
      m1 do |arg1, arg2|
        arg1 * arg2
      end
    end

    trait(:T3) do
      m1 do |arg1, arg2|
        arg1 + arg2
      end
    end
  end

  it 'Unresolved Trait' do
    c = Class.new {
      uses T1 + T2
    }
    obj = c.new
    expect { obj.m1(3) }.to raise_exception ArgumentError
  end

  it 'Secuential Resolver' do
    c = Class.new {
      resolve_traits :linear
      uses T1 + T2
    }
    obj= c.new
    expect(obj.m1(2)).to eq("t2.m1")

  end

  it 'Folding Resolver' do
    c = Class.new {
      resolve_traits :fold, proc { |concat, other| concat+other }
      uses T1 + T2
    }
    obj=c.new
    expect(obj.m1(2)).to eq("t1.m1t2.m1")

    d = Class.new {
      resolve_traits :fold, proc { |concat, other| concat+other }
      uses T3 + T4
    }
    obj=d.new
    expect(obj.m1(2, 2)).to eq(8)
  end

  it 'Comparator Resolver' do
    c = Class.new {
      resolve_traits :comparator, "t1.m1"
      uses T1 + T2
    }
    obj= c.new
    expect(obj.m1(2)).to eq("t1.m1")
  end
end