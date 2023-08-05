FactoryBot.define do
  factory :bulk_discount do
    discount { 1 }
    threshold { 1 }
    merchant { nil }
  end
end
