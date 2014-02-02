FactoryGirl.define do
  factory :project do
    name Random.rand(100_000).to_s

    trait :with_viewport do
      after(:create) do |project|
        project.viewport_widths = nil
        create :viewport, project: project
      end
    end

    trait :with_url do
      after(:create) do |project|
        project.url_addresses = nil
        create :url, project: project
      end
    end
  end

  factory :viewport do
    project
    width Random.rand(320..1200)
  end

  factory :url do
    association :project, :with_viewport
    address "http://www#{Random.rand(1_000)}.example.org"
  end

  factory :snapshot do
    url
    viewport
    title Random.rand(100_000).to_s
    after(:create) do |snapshot|
      snapshot.external_image_id = 'mocked_image'
      snapshot.save!
    end

    trait :accepted do
      accepted_at 1.day.ago
    end
  end
end
