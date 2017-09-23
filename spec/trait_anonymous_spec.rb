require 'rspec'
require_relative '../lib/trait'

describe 'AnonymousTrait' do

  before(:each) do

  end

  it 'Define anonymous trait' do
    a=Class.new {
      define_as_trait :magic_method do
        43
      end
    }

    obj=a.new
    expect(obj.magic_method).to eq(43)

    #Ask if it does exists the constant(Class) GenericTrait1
    expect { is_trait_defined?(:GenericTrait1) }.to raise_exception TraitException

    #Test to determine that is no other runtime generated trait.
    expect(is_trait_defined?(:GenericTrait3)).to eq(nil)

  end

  it 'Define anonymous trait that referes another method' do
    flying_class = Class.new {
      define_as_trait :do_something do
        self.meaning_of_life
      end

      def meaning_of_life
        42
      end
    }

    obj= flying_class.new
    expect(obj.do_something).to eq(42)

  end

end