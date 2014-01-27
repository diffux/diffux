FactoryGirl.define do
  factory :url do
    address "http://www#{Random.rand(1_000)}.example.org"
    viewport_width 320
    name 'Google start page'
  end

  factory :snapshot do
    url
    diffed_with_snapshot
  end
end
