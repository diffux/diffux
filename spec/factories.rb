FactoryGirl.define do
  factory :url do
    address "http://www#{Random.rand(1_000)}.example.org"
    viewport_width 320
    name 'Google start page'
  end

  factory :snapshot do
    url
    after(:create) do |snapshot|
      snapshot.external_image_id = 'mocked_image'
      snapshot.save!
    end
  end
end
