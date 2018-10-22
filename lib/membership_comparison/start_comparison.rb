# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    private

    def _conflict?
      false
    end

    def _partial?
      false
    end
  end
end
