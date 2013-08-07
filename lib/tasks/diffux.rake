namespace :diffux do
  desc "Takes snapshots for all URLs configured"

  task snapshot: :environment do
    Url.all.each do |url|
      if url.active?
        puts "Generating snapshot for '#{url.name}'..."
        url.snapshots.create!
        puts 'Done.'
      else
        puts "Skipping inactive configuration: '#{url.name}'"
      end
    end
  end
end
