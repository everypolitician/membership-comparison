module Wikidata
  class MembershipComparison
    def initialize(existing:, suggestion:)
      @existing = existing
      @suggestion = suggestion
    end

    def exact_matches
      classified.fetch(:exact, [])
    end

    def partial_matches
      classified.fetch(:partial, [])
    end

    def conflicts
      classified.fetch(:conflict, [])
    end

    private

    attr_reader :existing, :suggestion

    def classified
      @classified ||= existing.each_with_object({}) do |(id, statement), h|
        comparison = StatementComparison.new(statement: statement,
                                             suggestion: suggestion)
        state = comparison.state
        next unless state

        h[state] ||= []
        h[state] << id
      end
    end
  end

  class StatementComparison
    def initialize(statement:, suggestion:)
      @statement = statement
      @suggestion = suggestion
    end

    def state
      return unless statement[:position] == suggestion[:position]

      comparisons = field_comparisons

      if comparisons.all?(&:exact?)
        :exact
      elsif comparisons.any?(&:conflict?)
        :conflict
      elsif comparisons.any?(&:partial?)
        :partial
      end
    end

    private

    attr_reader :statement, :suggestion

    def field_comparisons
      [party_comparison, district_comparison, term_comparison, start_comparison]
    end

    def party_comparison
      PartyComparison.new(statement: statement, suggestion: suggestion)
    end

    def district_comparison
      DistrictComparison.new(statement: statement, suggestion: suggestion)
    end

    def term_comparison
      TermComparison.new(statement: statement, suggestion: suggestion)
    end

    def start_comparison
      StartComparison.new(statement: statement, suggestion: suggestion)
    end
  end

  class FieldComparison
    attr_reader :statement, :suggestion, :a, :b

    def self.field=(field)
      @field = field
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

      self.class.alias_method("statement_#{field}", :a)
      self.class.alias_method("suggestion_#{field}", :b)
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

  class PartyComparison < FieldComparison
    self.field = :party
  end

  class DistrictComparison < FieldComparison
    self.field = :district
  end

  class TermComparison < FieldComparison
    self.field = :term

    def conflict?
      false
    end

    def partial?
      false
    end
  end

  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      super || (
        ended? && started_lte_suggestion_term?
      )
    end

    def partial?
      super ||
        started_lte_suggestion_term?
    end

    private

    def started_lte_suggestion_term?
      statement_start && suggestion_term_start &&
        statement_start <= suggestion_term_start
    end

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
