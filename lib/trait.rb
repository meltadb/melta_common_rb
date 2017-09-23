require_relative 'resolver'

class TraitException < RuntimeError
end
class TraitConflictException < TraitException
end

class TraitBuilder
  def build(&block)
    @trait = SimpleTrait.new
    self.instance_eval(&block)
    if self.instance_variable_defined? :@trait_name
      @trait.name = @trait_name
      Object.const_set(@trait_name, @trait)
    end

    @trait
  end

  def name(symbol)
    @trait_name = symbol
  end

  def method(name, &implementation)
    @trait.add_method(name, implementation)
  end

  def method_missing(name, *args, &block)
    self.method(name, *args, &block)
  end

  def requirement
    Proc.new {
      raise "This method is required for the trait"
    }
  end

end

def trait(name = nil, &block)
  Trait.define do
    if !name.nil?
      name name
    else
      name define_anon_trait
    end
    instance_eval &block
  end
end

def define_as_trait(method_sym, &block)
  t = trait(nil) do
    method method_sym.to_sym, &block
  end
  t
end

def define_anon_trait(trait_number=1)
  begin
    trait_name = "GenericTrait#{trait_number}".to_sym
    is_trait_defined? trait_name
    trait_name
  rescue
    return define_anon_trait(trait_number+1)
  end

end

def is_trait_defined?(trait_name)
  raise TraitException.new('Trait existent') unless !Object.const_defined?(trait_name)
end

class Trait
  attr_accessor :name
  attr_reader :conflict_resolver, :clazz

  def +(rightTrait)
    TraitComposition.new(self, rightTrait)
  end

  def -(methodName)
    TraitSubstraction.new(self, methodName)
  end

  def <<(*aliases)
    TraitAlias.new(self, aliases)
  end

  def self.define(&block)
    TraitBuilder.new.build(&block)
  end

  def add_method(name, implementation)
    instance_methods[name] = implementation
  end

  def instance_methods
    raise "Subclass Responsibility"
  end

  def instance_method(name)
    instance_methods[name]
  end

  def define_trait_method_call(name, clazz, implementation)
    clazz.send(:define_method, name, implementation)
  end

  def add_to(clazz)
    @clazz = clazz
    @conflict_resolver = self.clazz.resolver_strategy

    instance_methods.each { |name, implementation|
      define_trait_method_call(name, self.clazz, implementation)
    }
  end

  def to_s
    @name.nil? ? '[Trait]AnonTrait' : "[Trait]#{@name}"
  end
end

class SimpleTrait < Trait
  def instance_methods
    @instance_methods ||= {}
  end
end

class TraitComposition < Trait

  def conflict(name)
    msg = "Unresolved conflict between #{@leftTrait} and #{@rightTrait} in method #{name}"
    proc { raise TraitConflictException.new(msg) }
  end

  def resolve_conflict(name, left_implementation, right_implementation)
    self.conflict_resolver.resolve_traits(self, name, left_implementation, right_implementation)
  end

  def instance_methods
    result = @leftTrait.instance_methods.clone
    @rightTrait.instance_methods.each { |name, implementation|
      result[name] = result.has_key?(name) ? (@conflict_resolver.nil? ? conflict(name) : resolve_conflict(name, result[name], implementation)) : implementation
    }

    result
  end

  def initialize(leftTrait, rightTrait)
    @leftTrait = leftTrait
    @rightTrait = rightTrait
  end

end

class TraitSubstraction < Trait

  def initialize(trait, substracted)
    @trait = trait
    @substracted = substracted
  end

  def instance_methods
    result = @trait.instance_methods.clone

    result.delete(@substracted)

    result
  end
end

class TraitAlias < Trait

  def initialize(trait, aliases)
    @trait = trait
    @aliases = Hash[aliases]
  end

  def instance_methods
    result = @trait.instance_methods.clone

    @aliases.each { |key, value|
      result[key] = result[value]
    }

    result
  end
end


class Class
  attr_accessor :resolver_strategy

  def resolver_strategy
    @resolver_strategy || nil
  end

  def uses(aTrait)
    aTrait.add_to self
  end

  def resolve_traits(method_sym, *args)
    mehtod = method_sym.to_s.capitalize
    self.resolver_strategy= "#{mehtod}Resolver".constantize.new args
  end

  def define_as_trait(method_sym, &block)
    t = trait(nil) do
      method method_sym.to_sym, &block
    end
    self.uses t
  end

  def not_nil?
    !nil?
  end

end

class String
  def constantize
    Object.const_get(self)
  end
end

class Symbol
  def >>(otherSymbol)
    [self, otherSymbol]
  end
end