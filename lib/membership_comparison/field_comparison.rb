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
      @state ||= begin
        if _exact? then :exact
        elsif _conflict? then :conflict
        elsif _partial? then :partial
        else :ignore
        end
      end
    end

    def exact?
      state == :exact
    end

    def ignore?
      state == :ignore
    end

    def conflict?
      state == :conflict
    end

    def partial?
      state == :partial
    end

    def conflict
      return "#{self.class.field} is a disambiguation" if disambiguation?
      return "#{self.class.field} conflict" if conflict?
    end

    private

    def disambiguation?
      suggestion[self.class.field]&.fetch(:disambiguation, false)
    end

    def _exact?
      (a == b || !b) && !disambiguation?
    end

    def _conflict?
      (a && b && a != b) || disambiguation?
    end

    def _partial?
      !_exact? && !_conflict?
    end

    def statement_value
      value = statement[self.class.field]
      return value[:id] if value.is_a?(Hash)

      value
    end
    alias a statement_value

    def suggestion_value
      value = suggestion[self.class.field]
      return value[:id] if value.is_a?(Hash)

      value
    end
    alias b suggestion_value
  end
end
