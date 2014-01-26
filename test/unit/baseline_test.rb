require 'test_helper'

class BaselineTest < ActiveSupport::TestCase
  test 'can only create one baseline per url' do
    # The first baseline is automatically created through fixture loading
    url = urls(:desktop)
    snapshot = snapshots(:one)
    baseline = Baseline.new(url_id: url.id, snapshot_id: snapshot.id)
    assert !baseline.save
  end
end
