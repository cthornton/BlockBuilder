module BlockBuilder
  class Builder
    
    attr_reader :_target_block, :_symbol_table, :_options, :_config_table


    def initialize(target_block, *args, &default_block)
      @_target_block = target_block
      options = {}
      options = args.pop if args.last.is_a?(Hash)
      args.each{|a| options[a] = true }
      @_options = options
      @_symbol_table = Hash.new
      @_config_table = Hash.new
      _build(default_block)
      _build(target_block)
    end
    
    
    def _build(block)
      instance_eval(&block) if block.is_a?(Proc)
    end
    
    def set(key, val)
      _config_table[key] = val
    end

    def method_missing(method, *args, &block)
      if _config_table.key?(method) and args.empty? and !block_given?
        return _config_table[method]
      end
      
      method = method.to_s.chomp('=').to_sym if method.to_s[-1] == "="
      
      attribute = _symbol_table[method]
      if attribute.nil?
        attribute = Attribute.new(self, method)
        _symbol_table[method] = attribute
      end
      
      # Read attribute if no params
      return attribute if args.empty? and !block_given?
      
      attribute.args  = args
      attribute.block = block if block_given?
      
      return attribute
    end   
    
    
  end
end
