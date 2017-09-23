require 'rspec'
require_relative './spec_helper'
require_relative '../lib/trait'

describe 'TraitOperations' do

  before(:each) do
    (Object.send(:remove_const, :T1)) rescue Exception
    (Object.send(:remove_const, :T2)) rescue Exception
    (Object.send(:remove_const, :T3)) rescue Exception

    Trait.define {
      name :T1

      method :m1 do
        "t1.m1"
      end

      method :m2 do
        "t1.m2"
      end

    }

    Trait.define {
      name :T2

      method :m3 do
        "t2.m3"
      end
    }

    Trait.define {
      name :T3

      method :m1 do
        "t3.m1"
      end

      method :m3 do
        "t3.m3"
      end
    }

  end

  describe 'TraitComposition' do
    it 'should use methods of both traits' do
      c = Class.new {
        uses T1 + T2
      }
      obj = c.new

      expect(obj.m1).to eq("t1.m1")
      expect(obj.m2).to eq("t1.m2")
      expect(obj.m3).to eq("t2.m3")
    end

    it 'should throw conflict error' do
      c = Class.new {
        uses T1 + T3
      }
      obj = c.new

      expect(obj.m2).to eq("t1.m2")
      expect(obj.m3).to eq("t3.m3")

      expect { objc.m1 }.to raise_error NameError
    end
  end

  describe 'TraitSubstraction' do
    it 'should substract a metod from a trait' do
      c = Class.new {
        uses T1 - :m1
      }
      obj = c.new

      expect(obj.m2).to eq("t1.m2")

      expect { obj.m1 }.to raise_error(NoMethodError)
    end

    it 'should resolve conflict error' do
      c = Class.new {
        uses T1 + (T3 - :m1)
      }
      obj = c.new

      expect(obj.m2).to eq("t1.m2")
      expect(obj.m3).to eq("t3.m3")

      obj.m1
      expect(obj.m1).to eq("t1.m1")
    end
  end

  describe 'TraitAlias' do
    it 'should create a new method' do
      c = Class.new {
        uses T1 << (:alias1 >> :m1)
      }
      obj = c.new

      expect(obj.m1).to eq("t1.m1")
      expect(obj.m2).to eq("t1.m2")
      expect(obj.alias1).to eq("t1.m1")

    end

    it 'should not resolve conflict error' do
      c = Class.new {
        uses (T1 << (:alias1 >> :m1)) + (T3 << (:alias2 >> :m1))
      }
      obj = c.new

      expect(obj.m2).to eq("t1.m2")
      expect(obj.m3).to eq("t3.m3")
      expect(obj.alias1).to eq("t1.m1")
      expect(obj.alias2).to eq("t3.m1")

      expect { obj.m1 }.to raise_error(TraitConflictException)

      c.send(:define_method, :m1) do
        self.alias1 + self.alias2
      end

      expect(obj.m1).to eq("t1.m1t3.m1")
    end
  end
end