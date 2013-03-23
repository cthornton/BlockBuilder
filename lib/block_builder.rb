require "block_builder/version"
require "block_builder/builder"
require "block_builder/attribute"

module BlockBuilder
  
  class << self
  
    def build(target_block, *options, &default_block)
      return BlockBuilder::Builder.new(target_block, *options, &default_block)
    end
  end
  
end
