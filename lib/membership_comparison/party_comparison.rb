# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class PartyComparison < FieldComparison
    self.field = :party

    def exact?
      !options[:require_party] || super
    end

    def conflict
      super if options[:require_party]
    end

    def partial?
      options[:require_party] && super
    end
  end
end
