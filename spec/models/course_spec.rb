# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course do
  describe 'validations' do
    subject(:course) { build(:course) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:year) }
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_numericality_of(:year).only_integer.is_greater_than(2000) }
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }

    context 'when ends_on is after starts_on' do
      subject(:course) { build(:course, starts_on: Date.parse('2022-01-01'), ends_on: Date.parse('2022-11-01')) }

      it { is_expected.to be_valid }
    end

    context 'when ends_on is equal to starts_on' do
      subject(:course) do
        build(:course, starts_on: Date.parse('2022-01-01'), ends_on: Date.parse('2022-01-01')).tap(&:valid?)
      end

      it { is_expected.not_to be_valid }
      it { expect(course.errors[:ends_on]).to include('must be greater than 2022-01-01') }
    end

    context 'when ends_on is before starts_on' do
      subject(:course) do
        build(:course, starts_on: Date.parse('2022-11-01'), ends_on: Date.parse('2022-01-01')).tap(&:valid?)
      end

      it { is_expected.not_to be_valid }
      it { expect(course.errors[:ends_on]).to include('must be greater than 2022-11-01') }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:teacher_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:teachers).through(:teacher_assignments) }
    it { is_expected.to have_many(:enrollments) }
    it { is_expected.to have_many(:exams) }
  end
end
