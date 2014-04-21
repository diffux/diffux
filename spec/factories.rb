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

    trait :with_snapshots do
      after(:create) do |project|
        # add the sweep
        sweep = create :sweep, project: project

        # add a viewport
        create :viewport, project: project

        # add three url_addresses
        # with identifiable names
        3.times do |i|
          url = create :url, project: project,
          address: "http://www#{i}.example.org"
          create(:snapshot, :with_baseline, :with_diff,
                 { url: url, sweep: sweep })
        end
      end
    end
  end

  factory :sweep do
    project
    title       Random.rand(20..100).to_s
    description Random.rand(100..1000).to_s
    email       'foo@bar.com'
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
      fixture_file_upload("#{Rails.root}/spec/sample_snapshot.png",
                          'image/png')
    end

    trait :with_diff do
      after(:create) do |snapshot|
        snapshot.create_snapshot_diff!(
          image_width: Random.rand(1000),
          diff_in_percent: 1.0,
          image: fixture_file_upload(
            "#{Rails.root}/spec/sample_snapshot.png", 'image/png'),
          before_snapshot: create(:snapshot)
        )
        snapshot.save!
      end
    end

    trait :with_baseline do
      after(:build) do |instance|
        create :snapshot, :accepted,
               url:      instance.url,
               viewport: instance.viewport
      end
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

  factory :snapshot_diff do
    association :before_snapshot, factory: :snapshot
    diff_in_percent 12.345
    image_height    100
    image_width     100

    image do
      fixture_file_upload("#{Rails.root}/spec/sample_snapshot.png",
                          'image/png')
    end
  end

  factory :snapshot_diff_cluster do
    snapshot_diff
    start  10
    finish 15
  end
end
