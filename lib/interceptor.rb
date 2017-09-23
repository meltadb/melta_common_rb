require 'thread'

class InterceptorException < StandardError; end

class Interceptor
  Thread.current[:current_pre_blocks] = []

  def self.before_method
    new.before_method
  end
  
  def before_method
    Thread.current[:current_pre_blocks] << self
  end

  def self.current_pre_blocks
    Thread.current[:current_pre_blocks].pop Thread.current[:current_pre_blocks].size
  end

end

module Interceptions
  def before_method(klass)
    if klass.is_a? Class
      klass.before_method
    else
      instance = klass
      raise InterceptorException.new 'Does not understand before_method' unless instance.class.method_defined? :before_method
      instance.before_method
    end
  end

  def method_added(name)
    super

    pre_blocks = Interceptor.current_pre_blocks
    return if pre_blocks.empty?

    pre_blocks.each do |pre_block|
      original_method = instance_method(name)
      define_method(name) do |*args, &block|
        super_method = original_method.bind(self)
        pre_block.call(super_method, *args, &block)
      end
    end

    visibility = if protected_method_defined? name
                   :protected
                 elsif private_method_defined? name
                   :private
                 else
                   :public
                 end

    case visibility
      when :protected
        protected name
      when :private
        private name
    end
  end

  def singleton_method_added(name)
    super

    pre_blocks = Interceptor.current_pre_blocks
    return if pre_blocks.empty?

    pre_blocks.each do |pre_block|
      original_method = method(name)
      define_singleton_method(name) do |*args, &block|
        pre_block.call(original_method, *args, &block)
      end
    end
  end
end
