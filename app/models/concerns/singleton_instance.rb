module SingletonInstance
  def self.included(base)
    class << base
      attr_reader :instance

      private

      def inherited(subclass)
        raise "Singleton class cannot be inherited" if self != subclass
      end
    end

    base.send :instance_variable_set, :@instance, base.send(:new)
    base.send :private_class_method, :new
  end
end
