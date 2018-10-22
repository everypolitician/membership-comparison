# frozen_string_literal: true

class MembershipComparison
  class FieldComparison
    attr_reader :statement, :suggestion, :options

    class << self
      attr_writer :field
    end

    def self.field
      @field || raise(NotImplementedError)
    end

    def initialize(statement:, suggestion:, options:)
      @statement = statement
      @suggestion = suggestion
      @options = options
    end

    def state
      @state = (
        if _exact? then :exact
        elsif _conflict? then :conflict
        elsif _partial? then :partial
        end
      )
    end

    def exact?
      state == :exact
    end

    def conflict?
      state == :conflict
    end

    def partial?
      state == :partial
    end

    def conflict
      "#{self.class.field} conflict" if conflict?
    end

    private

    def _exact?
      a == b
    end

    def _conflict?
      a && b && a != b
    end

    def _partial?
      !_exact? && !_conflict?
    end

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
