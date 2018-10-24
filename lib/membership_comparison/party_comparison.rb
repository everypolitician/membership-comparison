# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class PartyComparison < FieldComparison
    self.field = :party
  end
end
