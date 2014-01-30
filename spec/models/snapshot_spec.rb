require 'spec_helper'

describe Snapshot do
  describe 'rejecting/accepting' do
    let(:snapshot) { create(:snapshot) }
    subject        { snapshot }

    its(:accepted?) { should == false }
    its(:rejected?) { should == false }

    describe '#accept!' do
      before { snapshot.accept! }

      its(:accepted?) { should == true }
      its(:rejected?) { should == false }
    end

    describe '#reject!' do
      before { snapshot.reject! }

      its(:accepted?) { should == false }
      its(:rejected?) { should == true }
    end
  end
end
