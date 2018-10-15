# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class TermComparison < FieldComparison
    self.field = :term

    def conflict?
      false
    end

    def partial?
      false
    end
  end
end
