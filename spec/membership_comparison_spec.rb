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
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statements) { [] }

    it { is_expected.to be_actionable }
  end

  context 'when there are bare statements' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    let(:bare_1) { { position: mp } }
    let(:bare_2) { { position: mp, term: { id: nil }, party: { id: nil }, district: { id: nil } } }
    let(:statements) { [bare_1, bare_2] }

    it { is_expected.to be_actionable }
    specify { expect(bare_1).to be_a_partial_match }
    specify { expect(bare_2).to be_a_partial_match }
  end

  context 'when suggesting the previous term' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term42, party: liberal, district: pontiac } }

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when suggesting the next term' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term41, party: liberal, district: pontiac } }

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when suggesting the next term and a different district' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term41, party: liberal, district: quebec } }

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when suggesting an existing statement' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term42, party: liberal, district: pontiac } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_an_exact_match }
  end

  context 'when there are existing statements for previous and current terms' do
    let(:previous_statement) { { position: mp, term: term41, party: liberal, district: pontiac } }
    let(:current_statement) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statements) { [previous_statement, current_statement] }

    context 'when suggesting the previous term' do
      subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

      it { is_expected.not_to be_actionable }
      specify { expect(previous_statement).to be_an_exact_match }
      specify { expect(current_statement).to be_ignored }
    end

    context 'when suggesting the current term' do
      subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

      it { is_expected.not_to be_actionable }
      specify { expect(previous_statement).to be_ignored }
      specify { expect(current_statement).to be_an_exact_match }
    end
  end

  context 'when suggesting additional data' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term42 } }

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_a_partial_match }
  end

  context 'when suggesting a different party' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term42, party: conservative } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('party conflict') }
  end

  context 'when suggesting a different district' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term42, party: liberal, district: quebec } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('district conflict') }
  end

  context 'when suggesting a different position' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: speaker, term: term41, party: liberal, district: pontiac } }

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when not suggesting party even thought a statement has a party' do
    subject(:suggestion) { { position: mp, term: term42, party: { id: nil }, district: pontiac } }
    let(:statement) { { position: mp, term: term42, party: conservative, district: pontiac } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_an_exact_match }
  end

  context 'when suggesting term started the same day as a statement' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, start: '2015-12-03', party: liberal, district: pontiac } }

    # Statements:                 2015-12-03 ->
    # Term:       -> 2015-08-02 | 2015-12-03 ->

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_a_partial_match }
  end

  context 'when suggesting term started after a statement' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, start: '2015-10-18', party: liberal, district: pontiac } }

    # Statements:                 2015-10-18 ------------>
    # Term:       -> 2015-08-02 |            2015-12-03 ->

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_a_partial_match }
  end

  context 'when suggesting term started during a statement' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal, district: pontiac } }

    # Statements: 2011-06-02 ----------------------------> 2017-11-12
    # Term:                  -> 2015-08-02 | 2015-12-03 ->

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('spanning terms') }
  end

  context 'when suggesting term ending before a statement' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, start: '2015-12-03', party: liberal, district: pontiac } }

    # Statements:                                            2015-12-03 ->
    # Term:       -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when suggesting term between two other terms' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    let(:previous_statement) { { position: mp, term: term40, party: liberal, district: pontiac } }
    let(:next_statement) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statements) { [previous_statement, next_statement] }

    # Statements: 2008-11-18 -> 2011-03-26 |                          | 2015-12-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    it { is_expected.to be_actionable }
    specify { expect(previous_statement).to be_ignored }
    specify { expect(next_statement).to be_ignored }
  end

  context 'when suggesting term between two existing statement' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    let(:previous_statement) do
      { position: mp, start: '2008-11-18', end: '2011-03-26', party: liberal, district: pontiac }
    end
    let(:next_statement) { { position: mp, start: '2017-01-03', party: liberal, district: pontiac } }
    let(:statements) { [previous_statement, next_statement] }

    # Statements: 2008-11-18 -> 2011-03-26 |                          |            2017-01-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ------------>

    it { is_expected.to be_actionable }
    specify { expect(previous_statement).to be_ignored }
    specify { expect(next_statement).to be_ignored }
  end

  context 'when suggesting term between two other terms and matching term' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    let(:previous_statement) { { position: mp, term: term40, party: liberal, district: pontiac } }
    let(:statement) { { position: mp, term: term41, party: liberal, district: pontiac } }
    let(:next_statement) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:statements) { [previous_statement, statement, next_statement] }

    # Statements: 2008-11-18 -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ->

    it { is_expected.not_to be_actionable }
    specify { expect(previous_statement).to be_ignored }
    specify { expect(statement).to be_an_exact_match }
    specify { expect(next_statement).to be_ignored }
  end

  context 'when suggesting term between two statements and matching statement' do
    subject(:suggestion) { { position: mp, term: term41, party: liberal, district: pontiac } }

    let(:previous_statement) do
      { position: mp, start: '2008-11-18', end: '2011-03-26', party: liberal, district: pontiac }
    end
    let(:statement) do
      { position: mp, start: '2011-06-02', end: '2015-08-02', party: liberal, district: pontiac }
    end
    let(:next_statement) { { position: mp, start: '2017-01-03', party: liberal, district: pontiac } }
    let(:statements) { [previous_statement, statement, next_statement] }

    # Statements: 2008-11-18 -> 2011-03-26 | 2011-06-02 -> 2015-08-02 |            2017-01-03 ->
    # Term:                  -> 2011-03-26 | 2011-06-02 -> 2015-08-02 | 2015-12-03 ------------>

    it { is_expected.to be_actionable }
    specify { expect(previous_statement).to be_ignored }
    specify { expect(statement).to be_a_partial_match }
    specify { expect(next_statement).to be_ignored }
  end

  context 'when suggesting a start date after a statement within the same histrical term' do
    subject(:suggestion) { { position: mp, term: term42, start: '2017-01-03', party: liberal, district: pontiac } }
    let(:statement) { { position: mp, start: '2015-12-03', end: '2016-04-03', party: liberal, district: pontiac } }

    # Statements:                 2015-12-03 -> 2016-04-03 |
    # Term:       -> 2015-08-02 | 2015-12-03 ->            |
    # Suggestion:                                          | 2017-01-03 ->

    it { is_expected.to be_actionable }
    specify { expect(statement).to be_ignored }
  end

  context 'when there is a statement for a previous term which has not been closed' do
    context 'when suggesting the same term' do
      subject(:suggestion) { { position: mp, term: term42, start: '2017-01-03', party: liberal, district: pontiac } }
      let(:statement) { { position: mp, start: '2015-12-03', party: liberal, district: pontiac } }

      # Statements:                 2015-12-03 ------------>
      # Term:       -> 2015-08-02 | 2015-12-03 ------------>
      # Suggestion:                            2017-01-03 ->

      it { is_expected.not_to be_actionable }
      specify { expect(statement).to be_a_conflict.with_problem('previous term still open') }
    end

    context 'when suggesting the current term' do
      subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
      let(:statement) { { position: mp, term: term42, start: '2016-03-03', party: liberal, district: pontiac } }

      # Statements: 2015-03-10 ------------> |
      # Term:                  -> 2015-08-02 | 2015-12-03 ->

      it { is_expected.not_to be_actionable }
      specify { expect(statement).to be_an_exact_match }
    end

    context 'when suggesting the next term' do
      subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
      let(:statement) { { position: mp, start: '2015-03-10', party: liberal, district: pontiac } }

      # Statements:                            2016-03-03 ->
      # Term:       -> 2015-08-02 | 2015-12-03 ------------>
      # Suggestion:                 2015-12-03 ------------>

      it { is_expected.not_to be_actionable }
      specify { expect(statement).to be_a_conflict.with_problem('previous term still open') }
    end
  end

  context 'when suggesting a disambiguation person' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac, person: person } }
    let(:person) { { disambiguation: true } }

    let(:statement) { { position: mp, term: term42, party: liberal, district: pontiac } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('person is a disambiguation') }
  end

  context 'when suggesting a disambiguation party' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:liberal) { { id: 'Q138345', disambiguation: true } }

    let(:statement) { { position: mp, term: term42, party: liberal, district: pontiac } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('party is a disambiguation') }
  end

  context 'when suggesting a disambiguation district' do
    subject(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
    let(:pontiac) { { id: 'Q3397734', disambiguation: true } }

    let(:statement) { { position: mp, term: term42, party: liberal, district: pontiac } }

    it { is_expected.not_to be_actionable }
    specify { expect(statement).to be_a_conflict.with_problem('district is a disambiguation') }
  end

  context 'when there are existing statements for a superclass position' do
    let(:subclass) { term_specific_mp }
    let(:superclass) { mp }

    let(:mp) { { id: 'Q16707842' } } # Member of Parliament of the United Kingdom
    let(:term_specific_mp) { { id: 'Q30524710' } } # Member of the 57th Parliament of the United Kingdom

    let(:term56) { { id: 'Q21084473' } }
    let(:term57) { { id: 'Q29974940' } }
    let(:greens) { { id: 'Q9669' } }
    let(:brighton) { { id: 'Q1070099' } }

    xcontext 'when the statement is bare' do
      subject(:suggestion) do
        { position: subclass, position_parent: superclass, term: term57, party: greens, district: brighton }
      end

      let(:statement) { { position: superclass, term: {} } }

      it { is_expected.to be_actionable }
      specify { expect(statement).to be_ignored }
    end

    xcontext 'when suggesting the same data' do
      subject(:suggestion) do
        { position: subclass, position_parent: superclass, term: term57, party: greens, district: brighton }
      end

      let(:statement) { { position: superclass, term: term57, party: greens, district: brighton } }

      it { is_expected.not_to be_actionable }
      specify { expect(statement).to be_a_conflict.with_problem('position conflict') }
    end

    xcontext 'when suggesting additional data' do
      subject(:suggestion) do
        { position: subclass, position_parent: superclass, term: term57, party: greens, district: brighton }
      end

      let(:statement) { { position: superclass, party: greens } }

      it { is_expected.not_to be_actionable }
      specify { expect(statement).to be_a_conflict.with_problem('position conflict') }
    end

    xcontext 'when suggestion new data' do
      subject(:suggestion) do
        { position: subclass, position_parent: superclass, term: term57, party: greens, district: brighton }
      end

      let(:statement) { { position: superclass, term: term56, party: greens, district: brighton } }

      it { is_expected.to be_actionable }
      specify { expect(statement).to be_ignored }
    end
  end
end
