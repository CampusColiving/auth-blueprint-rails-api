module ActiveZuora

  module Scoping

    module ClassMethods

      def find_by(conditions)
        where(conditions).first
      end

      def find_by!(conditions)
        find_by(conditions) or raise Zuora::RecordNotFound # rubocop:disable AndOr
      end

      def find!(id)
        find(id) or raise Zuora::RecordNotFound # rubocop:disable AndOr
      end

    end

  end

end
