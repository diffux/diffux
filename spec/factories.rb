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

  factory :sweep do
    project
    title       Random.rand(20..100).to_s
    description Random.rand(100..1000).to_s
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

    image do
      fixture_file_upload("#{Rails.root}/spec/sample_snapshot.png", 'image/png')
    end

    trait :with_diff do
      diff_image do
        fixture_file_upload("#{Rails.root}/spec/sample_snapshot.png", 'image/png')
      end
      diff_from_previous 1.0
      association :diffed_with_snapshot, factory: :snapshot
    end

    trait :with_sweep do
      sweep
    end

    trait :accepted do
      with_diff
      accepted_at 1.day.ago
    end

    trait :rejected do
      with_diff
      rejected_at 1.day.ago
    end

    trait :pending do
      image nil
    end
  end
end
