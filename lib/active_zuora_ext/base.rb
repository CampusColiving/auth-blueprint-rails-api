module ActiveZuora

  module Base

    def as_json(*)
      attributes.except(*self.class.excluded_from_json)
    end

    module ClassMethods

      def exclude_from_json(*field_names)
        (@excluded_from_json ||= []).concat field_names.map(&:to_s)
      end

      def excluded_from_json
        @excluded_from_json ||= []
      end

    end

  end

end
