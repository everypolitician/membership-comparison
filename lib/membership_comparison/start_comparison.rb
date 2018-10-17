# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      suggestion_started_during_statement? &&
        (suggestion_open? || suggestion_ended_after_statement?)
    end

    def partial?
      suggestion_started_during_statement? ||
        (suggestion_open? && suggestion_started_after_statement?)
    end

    private

    def suggestion_started_during_statement?
      return false unless statement_closed? && suggestion_started?

      statement_start <= suggestion_start && suggestion_start < statement_end
    end

    def suggestion_ended_after_statement?
      return false unless statement_closed? && suggestion_closed?

      statement_end < suggestion_end
    end

    def suggestion_started_after_statement?
      return false unless statement_started? && suggestion_started?

      statement_start <= suggestion_start
    end

    def statement_started?
      statement_start
    end

    def statement_closed?
      statement_started? && statement_end
    end

    def statement_open?
      !statement_closed?
    end

    def suggestion_started?
      suggestion_start
    end

    def suggestion_closed?
      suggestion_started? && suggestion_end
    end

    def suggestion_open?
      !suggestion_closed?
    end

    def statement_start
      statement[:start]
    end

    def statement_end
      statement[:end]
    end

    def suggestion_start
      suggestion.dig(:term, :start)
    end

    def suggestion_end
      suggestion.dig(:term, :end)
    end
  end
end
