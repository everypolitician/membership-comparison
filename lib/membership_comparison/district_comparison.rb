# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class DistrictComparison < FieldComparison
    self.field = :district
  end
end
