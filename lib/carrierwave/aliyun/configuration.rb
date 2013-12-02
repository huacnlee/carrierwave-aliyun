module CarrierWave
  module Aliyun
    module Configuration
      extend ActiveSupport::Concern
      included do
        add_config :aliyun_access_id
        add_config :aliyun_access_key
        add_config :aliyun_bucket
        add_config :aliyun_area
        add_config :aliyun_internal
        add_config :aliyun_host
      end
    end
    
    module ClassMethods
      def add_config(name)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.#{name}(value=nil)
            @#{name} = value if value
            return @#{name} if self.object_id == #{self.object_id} || defined?(@#{name})
            name = superclass.#{name}
            return nil if name.nil? && !instance_variable_defined?("@#{name}")
            @#{name} = name && !name.is_a?(Module) && !name.is_a?(Symbol) && !name.is_a?(Numeric) && !name.is_a?(TrueClass) && !name.is_a?(FalseClass) ? name.dup : name
          end

          def self.#{name}=(value)
            @#{name} = value
          end

          def #{name}
            value = self.class.#{name}
            value.instance_of?(Proc) ? value.call : value
          end
        RUBY
      end   
    end
  end
end