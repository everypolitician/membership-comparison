# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      super || ended?
    end

    private

    def ended?
      statement_end && statement_start < statement_end
    end

    def statement_end
      statement[:end]
    end

    def suggestion_term_start
      suggestion.dig(:term, :start)
    end
  end
end
