require 'spec_helper'
describe Project do
  let!(:project) { create(:project) }

  describe '#destroy' do
    subject { project.destroy }

    it 'deletes the project' do
      expect { subject }.to change { Project.all.count }.by(-1)
    end

    context 'with a sweep' do
      let!(:sweep_id) { create(:sweep, project: project).id }

      it 'cascade-deletes the sweep too' do
        subject
        expect { Sweep.find(sweep_id) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
