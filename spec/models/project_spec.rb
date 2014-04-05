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

    context 'with a viewport' do
      let!(:viewport_id) { create(:viewport, project: project).id }

      it 'cascade-deletes the viewport too' do
        subject
        expect { Viewport.find(viewport_id) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a url' do
      let!(:url_id) { create(:url, project: project).id }

      it 'cascade-deletes the url too' do
        subject
        expect { Url.find(url_id) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
