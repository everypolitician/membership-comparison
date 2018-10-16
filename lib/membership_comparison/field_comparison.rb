# frozen_string_literal: true

class MembershipComparison
  class FieldComparison
    attr_reader :statement, :suggestion, :a, :b

    class << self
      attr_writer :field
    end

    def self.field
      @field || raise(NotImplementedError)
    end

    def initialize(statement:, suggestion:)
      field = self.class.field

      @statement = statement
      @suggestion = suggestion
      @a = statement[field]
      @b = suggestion[field]
    end

    def exact?
      a == b
    end

    def conflict?
      a && b && a != b
    end

    def partial?
      !exact? && !conflict?
    end
  end
end
