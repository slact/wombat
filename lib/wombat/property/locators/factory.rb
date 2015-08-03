#coding: utf-8
require 'wombat/property/locators/base'
require 'wombat/property/locators/follow'
require 'wombat/property/locators/html'
require 'wombat/property/locators/iterator'
require 'wombat/property/locators/property_group'
require 'wombat/property/locators/list'
require 'wombat/property/locators/text'
require 'wombat/property/locators/headers'

class Wombat::Property::Locators::UnknownTypeException < Exception; end;

module Wombat
  module Property
    module Locators
      module Factory
        def self.locator_for(property)
          propform= property.wombat_property_format
          klass = case(propform)
          when :text
            Text
          when :list
            List
          when :html
            Html
          when :iterator
            Iterator
          when :container
            PropertyGroup
          when :follow
            Follow
          when :headers
            Headers
          else
            attr_match = propform.to_s.match(/^attr=(.*)/)
            if attr_match
              Class.new(Locators::Base) do
                @@attr= attr_match[1]
                def locate(context, page = nil)
                  node = locate_nodes(context)
                  node = node.first unless node.is_a?(String)
                  unless node
                    value = nil
                  else 
                    value = node.attributes[@@attr].to_s
                  end
                  super { value }
                end
              end
            else
              raise Wombat::Property::Locators::UnknownTypeException.new("Unknown property format #{property.format}.")
            end
          end
          klass.new(property)
        end
      end
    end
  end
end
