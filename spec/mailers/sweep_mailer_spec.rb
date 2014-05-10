require 'spec_helper'

describe SweepMailer do
  describe '#ready_for_review' do
    let(:sweep)   { create :sweep }
    let(:message) { SweepMailer.ready_for_review(sweep) }

    it 'renders a URL to the sweep project' do
      message.body.encoded.should include project_sweep_url(id: sweep,
                                                            project_id: sweep.project)
    end

    it "sets the sweep's email as the To header" do
      message[:To].value.should == sweep.email
    end

    it 'sets a From header containing a name and address' do
      message[:From].value.should == 'Diffux <no-reply@diffux>'
    end

    it 'has the right subject' do
      message.subject.should == "Re: #{sweep.title}"
    end
  end
end
