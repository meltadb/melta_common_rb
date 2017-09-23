require_relative 'abstract'

class Resolver
  extend Abstract
  abstract_methods :define_new_block

  def resolve_traits(trait, original_name, left_trait_impl, right_trait_impl)
    #get params from one of the blocks
    @parameters = left_trait_impl.parameters.map { |p| p[1] }

    #get method names and redefine them
    @left_method = self.convert_method_name(original_name, 'left')
    @right_method = self.convert_method_name(original_name, 'right')
    self.redefine_implementation(trait, @left_method, left_trait_impl)
    self.redefine_implementation(trait, @right_method, right_trait_impl)
    puts @parameters.class
    self.define_new_block(@left_method, @right_method)
  end

  def redefine_implementation(trait, new_name, implementation)
    clazz = trait.clazz
    trait.define_trait_method_call(new_name, clazz, implementation)
  end

  def convert_method_name(sym, text)
    "__#{text}#{sym.to_s}___".to_sym
  end
end

class LinearResolver < Resolver

  def initialize(*args)

  end

  def define_new_block(left_method, right_method)
    Proc.new { |*params|
      self.send(left_method, *params)
      self.send(right_method, *params)
    }
  end

end

class FoldResolver < Resolver

  def initialize(*args)
    @function = args[0]
  end

  def define_new_block(left_method, right_method)
    function = @function[0]
    Proc.new { |*params|
      ret_left = self.send left_method, *params
      ret_right = self.send right_method, *params
      [ret_left, ret_right].inject &function
    }
  end

end

class ComparatorResolver < Resolver
  def initialize(*args)
    @compare_result = args[0]
  end

  def define_new_block(left_method, right_method)
    compare_result = @compare_result[0]
    Proc.new { |*params|
      [left_method, right_method].each { |method|
        ret = self.send(method, *params)
        if ret.eql? compare_result
          return ret
        end
      }
    }
  end
end