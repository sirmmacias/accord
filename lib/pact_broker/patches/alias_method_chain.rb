unless Module.method_defined?(:alias_method_chain)
  class Module
    def alias_method_chain(target, feature)
      # Strip out punctuation on predicates, bang methods, or assignment methods
      feature = feature.to_s.sub(/[?!=]$/, "")

      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ""), $1
      yield(aliased_target, punctuation) if block_given?

      with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
      without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

      alias_method without_method, target
      alias_method target, with_method

      case
      when public_method_defined?(without_method)
        public target
      when protected_method_defined?(without_method)
        protected target
      when private_method_defined?(without_method)
        private target
      end
    end
  end
end
