namespace :diffux do
  desc "Takes snapshots for all URLs configured"

  task snapshot: :environment do
    Url.all.each do |url|
      puts "Generating snapshot for '#{url.name}'..."
      url.snapshots.create!
      puts 'Done.'
    end
  end
end
