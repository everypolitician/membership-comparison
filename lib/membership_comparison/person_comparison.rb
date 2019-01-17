# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class PersonComparison < FieldComparison
    self.field = :person
  end
end
