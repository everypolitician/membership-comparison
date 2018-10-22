# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class PartyComparison < FieldComparison
    self.field = :party

    private

    def _exact?
      !options[:require_party] || super
    end

    def _conflict?
      options[:require_party] && super
    end

    def _partial?
      options[:require_party] && super
    end
  end
end
