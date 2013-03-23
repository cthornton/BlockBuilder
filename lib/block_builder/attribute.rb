module BlockBuilder
  class Attribute
    
    attr_accessor :name, :block, :args, :parent_builder
    
    def initialize(parent_builder, name, args = nil, block = nil)
      @name = name
      @args = args || []
      @block = block
      @parent_builder = parent_builder
    end
    
    
    #def set_block(some_block)
    #  block = some_block
    #  # builder._build(some_block) if some_block.is_a?(Proc)
    #end
    
    #def builder
    #  @builder = BlockBuilder::Builder.new(block) if @builder.nil?
    #  return @builder
    #end
    
    def call(*args)
      block.call(*args) if block?
    end
    
    def block?
      block.is_a?(Proc)
    end
    
    def blank?
      args.empty? and !block?
    end
    
    def val; args.first; end
    def value; val; end
    def to_s; val; end
    
    def vals; args; end
    def values; vals; end
    
    
    
  end
end
