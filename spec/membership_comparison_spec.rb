# frozen_string_literal: true

require_relative './spec_helper'
require_relative './membership_comparison_support'
require_relative '../lib/membership_comparison'

describe MembershipComparison do
  include_context 'spec setup'

  let(:mp) { { id: 'Q15964890' } }
  let(:speaker) { { id: 'Q2506685' } }
  let(:liberal) { { id: 'Q138345' } }
  let(:conservative) { { id: 'Q488523' } }
  let(:pontiac) { { id: 'Q3397734' } }
  let(:quebec) { { id: 'Q3414825' } }
  let(:term40) { { id: 'Q2816734', eopt: '2008-09-07', start: '2008-11-18', end: '2011-03-26', sont: '2011-06-02' } }
  let(:term41) { { id: 'Q2816776', eopt: '2011-03-26', start: '2011-06-02', end: '2015-08-02', sont: '2015-12-03' } }
  let(:term42) { { id: 'Q21157957', eopt: '2015-08-02', start: '2015-12-03' } }

  context 'when there are no statements' do
    let(:existing) { [] }
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
  end

  context 'when there are bare statements' do
    let(:existing) do
      [
        { position: mp },
        { position: mp, term: { id: nil }, party: { id: nil }, district: { id: nil } },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_a_partial_match }
    specify { expect(existing[1]).to be_a_partial_match }
  end

  context 'when suggesting the previous term' do
    let(:existing) do
      [
        { position: mp, term: term41, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when suggesting the next term' do
    let(:existing) do
      [
        { position: mp, term: term41, party: liberal, district: quebec },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when suggesting the next term and a different district' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when suggesting an existing statement' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_an_exact_match }
  end

  context 'when there are existing statements for previous and current terms' do
    context 'when suggesting the previous term' do
      let(:existing) do
        [
          { position: mp, term: term41, party: liberal, district: pontiac },
          { position: mp, term: term42, party: liberal, district: pontiac },
        ]
      end
      let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

      specify { expect(suggestion).not_to be_actionable }
      specify { expect(existing[0]).to be_ignored }
      specify { expect(existing[1]).to be_an_exact_match }
    end

    context 'when suggesting the current term' do
      let(:existing) do
        [
          { position: mp, term: term41, party: liberal, district: pontiac },
          { position: mp, term: term42, party: liberal, district: pontiac },
        ]
      end
      let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

      specify { expect(suggestion).not_to be_actionable }
      specify { expect(existing[0]).to be_an_exact_match }
      specify { expect(existing[1]).to be_ignored }
    end
  end

  context 'when suggesting additional data' do
    let(:existing) do
      [
        { position: mp, term: term42 },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_a_partial_match }
  end

  context 'when suggesting a different party' do
    let(:existing) do
      [
        { position: mp, term: term42, party: conservative },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('party conflict') }
  end

  context 'when suggesting a different district' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: quebec },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('district conflict') }
  end

  context 'when suggesting a different position' do
    let(:existing) do
      [
        { position: speaker, term: term41, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when not suggesting party even thought a statement has a party' do
    let(:existing) do
      [
        { position: mp, term: term42, party: conservative, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: { id: nil }, district: pontiac } }

    specify { expect(suggestion).not_to be_actionable }
  end

  context 'when suggesting term started the same day as a statement' do
    let(:existing) do
      [
        { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    # Statements:                 2015-12-03 ->
    # Term:       -> 2015-08-02 | 2015-12-03 ->

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_a_partial_match }
  end

  context 'when suggesting term started after a statement' do
    let(:existing) do
      [
        { position: mp, start: '2015-10-18', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    # Statements:                 2015-10-18 ------------>
    # Term:       -> 2015-08-02 |            2015-12-03 ->

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_a_partial_match }
  end

  context 'when suggesting term started during a statement' do
    let(:existing) do
      [
        { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    # Statements: 2011-06-02 ----------------------------> 2017-11-12
    # Term:                  -> 2015-08-02 | 2015-12-03 ->

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('spanning terms') }
  end

  context 'when suggesting term ending before a statement' do
    let(:existing) do
      [
        { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    # Statements:                                            2015-12-03 ->
    # Term:       -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when suggesting term between two other terms' do
    let(:existing) do
      [
        { position: mp, term: term40, party: liberal, district: pontiac },
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    # Statements: 2008-11-18 -> 2011-03-26 |                          | 2015-12-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
    specify { expect(existing[1]).to be_ignored }
  end

  context 'when suggesting term between two existing statement' do
    let(:existing) do
      [
        { position: mp, start: '2008-11-18', end: '2011-03-26', party: liberal, district: pontiac },
        { position: mp, start: '2017-01-03', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    # Statements: 2008-11-18 -> 2011-03-26 |                          |            2017-01-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ------------>

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
    specify { expect(existing[1]).to be_ignored }
  end

  context 'when suggesting term between two other terms and matching term' do
    let(:existing) do
      [
        { position: mp, term: term40, party: liberal, district: pontiac },
        { position: mp, term: term41, party: liberal, district: pontiac },
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    # Statements: 2008-11-18 -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_ignored }
    specify { expect(existing[1]).to be_an_exact_match }
    specify { expect(existing[2]).to be_ignored }
  end

  context 'when suggesting term between two statements and matching statement' do
    let(:existing) do
      [
        { position: mp, start: '2008-11-18', end: '2011-03-26', party: liberal, district: pontiac },
        { position: mp, start: '2011-06-02', end: '2015-08-02', party: liberal, district: pontiac },
        { position: mp, start: '2017-01-03', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    # Statements: 2008-11-18 -> 2011-03-26 | 2011-06-02 -> 2015-08-02 |            2017-01-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ------------>

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
    specify { expect(existing[1]).to be_a_partial_match }
    specify { expect(existing[2]).to be_ignored }
  end

  context 'when suggesting a start date after a statement within the same histrical term' do
    let(:existing) do
      [
        { position: mp, start: '2015-12-03', end: '2016-04-03', party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, start: '2017-01-03', party: liberal, district: pontiac } }

    # Statements:                 2015-12-03 -> 2016-04-03 |
    # Term:       -> 2015-08-02 | 2015-12-03 ->            |
    # Suggestion:                                          | 2017-01-03 ->

    specify { expect(suggestion).to be_actionable }
    specify { expect(existing[0]).to be_ignored }
  end

  context 'when there is a statement for a previous term which has not been closed' do
    context 'when suggesting the same term' do
      let(:existing) do
        [
          { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
        ]
      end
      let(:suggestion) { { position: mp, term: term42, start: '2017-01-03', party: liberal, district: pontiac } }

      # Statements:                 2015-12-03 ------------>
      # Term:       -> 2015-08-02 | 2015-12-03 ------------>
      # Suggestion:                            2017-01-03 ->

      specify { expect(suggestion).not_to be_actionable }
      specify { expect(existing[0]).to be_a_conflict.with_problem('previous term still open') }
    end

    context 'when suggesting the current term' do
      let(:existing) do
        [
          { position: mp, term: term42, start: '2016-03-03', party: liberal, district: pontiac },
        ]
      end
      let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

      # Statements:                            2016-03-03 ->
      # Term:       -> 2015-08-02 | 2015-12-03 ------------>
      # Suggestion:                 2015-12-03 ------------>

      specify { expect(suggestion).not_to be_actionable }
      specify { expect(existing[0]).to be_an_exact_match }
    end

    context 'when suggesting the next term' do
      let(:existing) do
        [
          { position: mp, start: '2015-03-10', party: liberal, district: pontiac },
        ]
      end
      let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

      # Statements: 2015-03-10 ------------> |
      # Term:                  -> 2015-08-02 | 2015-12-03 ->

      specify { expect(suggestion).not_to be_actionable }
      specify { expect(existing[0]).to be_a_conflict.with_problem('previous term still open') }
    end
  end

  context 'when suggesting a disambiguation person' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) do
      { position: mp, term: term42, party: liberal, district: pontiac, person: { disambiguation: true } }
    end

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('person is a disambiguation') }
  end

  context 'when suggesting a disambiguation party' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:liberal) { { id: 'Q138345', disambiguation: true } }

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('party is a disambiguation') }
  end

  context 'when suggesting a disambiguation district' do
    let(:existing) do
      [
        { position: mp, term: term42, party: liberal, district: pontiac },
      ]
    end
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:pontiac) { { id: 'Q3397734', disambiguation: true } }

    specify { expect(suggestion).not_to be_actionable }
    specify { expect(existing[0]).to be_a_conflict.with_problem('district is a disambiguation') }
  end
end
