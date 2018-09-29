# frozen_string_literal: true

require_relative './spec_helper'
require_relative '../lib/membership_comparison'

describe MembershipComparison do
  let(:mp) { { id: 'Q15964890' } }
  let(:speaker) { { id: 'Q2506685' } }
  let(:liberal) { { id: 'Q138345' } }
  let(:conservative) { { id: 'Q488523' } }
  let(:pontiac) { { id: 'Q3397734' } }
  let(:term41) { { id: 'Q2816776', start: '2011-06-02', end: '2015-08-02' } }
  let(:term42) { { id: 'Q21157957', start: '2015-12-03' } }
  let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
  let(:suggestion41) { { position: mp, term: term41, party: liberal, district: pontiac } }

  context 'no existing P39s' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {},
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'single existing P39, previous term' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'single existing P39, following term' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
        },
        suggestion: suggestion41
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'single existing P39, exact match' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to match_array(['wds:1030-1DAA-3101']) }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'multiple existing P39s, current exact match' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to match_array(['wds:1030-1DAA-3101']) }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'multiple existing P39s, historic exact match' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
        },
        suggestion: suggestion41
      )
    end

    specify { expect(comparison.exact_matches).to match_array(['wds:1030-1DAA-3100']) }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'single existing P39, partial match' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3102' => { position: mp, term: term42 },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to match_array(['wds:1030-1DAA-3102']) }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'single existing P39, conflict' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3102' => { position: mp, term: term42, party: conservative },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to match_array(['wds:1030-1DAA-3102']) }
  end

  context 'single existing P39, different position' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-4100' => { position: speaker, term: term41, party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'existing dated P39, within term' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3103' => { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to match_array(['wds:1030-1DAA-3103']) }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'existing dated P39 between terms' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3104' => { position: mp, start: '2015-10-18', party: liberal, district: pontiac },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to match_array(['wds:1030-1DAA-3104']) }
    specify { expect(comparison.conflicts).to be_empty }
  end

  context 'existing dated P39 spanning terms' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3105' => { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal,
                                    district: pontiac, },
        },
        suggestion: suggestion
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to match_array(['wds:1030-1DAA-3105']) }
  end

  context 'existing dated P39, later term' do
    let(:comparison) do
      MembershipComparison.new(
        existing:   {
          'wds:1030-1DAA-3103' => { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
        },
        suggestion: suggestion41
      )
    end

    specify { expect(comparison.exact_matches).to be_empty }
    specify { expect(comparison.partial_matches).to be_empty }
    specify { expect(comparison.conflicts).to be_empty }
  end
end
