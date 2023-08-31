# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence :name, %w[Matemática Português História Geografia Física Química Inglês].cycle
  end
end
