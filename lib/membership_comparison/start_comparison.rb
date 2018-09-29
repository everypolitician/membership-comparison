# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      super || ended?
    end

    def partial?
      super && started_before_term_ended?
    end

    private

    def ended?
      statement_end && statement_start < statement_end
    end

    def started_before_term_ended?
      !statement_start || !suggestion_term_end || statement_start <= suggestion_term_end
    end

    def statement_start
      statement[:start]
    end

    def statement_end
      statement[:end]
    end

    def suggestion_term_start
      suggestion.dig(:term, :start)
    end

    def suggestion_term_end
      suggestion.dig(:term, :end)
    end
  end
end
