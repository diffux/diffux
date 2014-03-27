require 'spec_helper'

describe DiffClusterFinder do
  let(:rows)   { 100 }
  let(:finder) { DiffClusterFinder.new(rows) }

  describe '#clusters' do
    subject { finder.clusters }

    context 'when no different rows have been reported' do
      it { should be_empty }
    end

    context 'when the first row is different' do
      before { finder.row_is_different(0) }

      it 'has one cluster' do
        subject.count.should == 1
      end

      it 'has a cluster starting at 0' do
        subject.first[:start].should == 0
      end

      it 'has a cluster ending at 0' do
        subject.first[:finish].should == 0
      end
    end

    context 'when the last four rows are different' do
      before do
        4.times { |i| finder.row_is_different(rows - i - 1) }
      end

      it 'has one cluster' do
        subject.count.should == 1
      end

      it 'has a cluster starting at the right row' do
        subject.first[:start].should == rows - 4
      end

      it 'has a cluster ending at the last line' do
        subject.first[:finish].should == rows - 1
      end
    end

    context 'with two clusters' do
      before do
        finder.row_is_different(20)
        finder.row_is_different(23)
        finder.row_is_different(27)

        finder.row_is_different(60)
        finder.row_is_different(61)
      end

      it 'has two clusters' do
        subject.count.should == 2
      end

      it 'has a correct first cluster' do
        subject.first[:start].should  == 20
        subject.first[:finish].should == 27
      end

      it 'has a correct second cluster' do
        subject[1][:start].should  == 60
        subject[1][:finish].should == 61
      end
    end

    context 'with all rows different' do
      before do
        rows.times { |i| finder.row_is_different(i) }
      end

      it 'has one cluster' do
        subject.count.should == 1
      end

      it 'has a cluster starting at the first row' do
        subject.first[:start].should == 0
      end

      it 'has a cluster ending at the last line' do
        subject.first[:finish].should == rows - 1
      end
    end
  end

  describe '#percent_of_rows_different' do
    subject { finder.percent_of_rows_different }

    context 'when no different rows have been reported' do
      it { should == 0.0 }
    end

    context 'when one row is different' do
      before { finder.row_is_different(0) }

      it 'reports a one percent difference' do
        subject.should == 1.0
      end
    end
  end
end
