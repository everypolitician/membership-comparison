# frozen_string_literal: true

class MembershipComparison
  class FieldComparison
    attr_reader :statement, :suggestion

    class << self
      attr_writer :field
    end

    def self.field
      @field || raise(NotImplementedError)
    end

    def initialize(statement:, suggestion:)
      @statement = statement
      @suggestion = suggestion
    end

    def exact?
      a == b
    end

    def conflict
      "#{self.class.field} conflict" if a && b && a != b
    end

    def conflict?
      !conflict.nil?
    end

    def partial?
      !exact? && !conflict?
    end

    private

    def statement_value
      statement[self.class.field]
    end
    alias a statement_value

    def suggestion_value
      suggestion[self.class.field]
    end
    alias b suggestion_value
  end
end
