require 'spec_helper'

describe ProjectsController do
  render_views

  describe '#index' do
    subject do
      get :index
      response
    end

    context 'with no added Projects' do
      it { should be_success }
      it { should render_template('projects/index') }

      its(:body) do
        should have_link('Add new Project', href: new_project_path)
      end
    end

    context 'with one Project' do
      let(:project) { create :project }

      it { should be_success }
      it { should render_template('projects/index') }

      its(:body) do
        should have_link('Add new Project', href: new_project_path)
      end

      its(:body) do
        should have_link(project.name, href: project_path(project))
      end

      context 'with one sweep' do
        let!(:sweep) { create :sweep }

        its(:body) do
          should have_link(nil, href: project_sweep_path(sweep.project, sweep))
        end
      end
    end

  end

  describe '#show' do
    let(:project) { create :project, :with_viewport }

    subject do
      get :show, id: project.to_param
      response
    end

    it { should be_success }
    it { should render_template('projects/show') }
    its(:body) { should include project.name }
    its(:body) { should include edit_project_path(project) }

    context 'with urls' do
      let(:url)  { create :url, project: project }

      its(:body) { should include url.address }
    end

    context 'with sweeps' do
      let!(:sweep) { create :sweep, project: project }
      let!(:older_sweep) do
        create :sweep, project: project, created_at: 2.days.ago
      end
      its(:body) { should include 'Last Sweep' }
      its(:body) { should include sweep.title }
    end
  end

  describe '#new' do
    subject do
      get :new
      response
    end

    it { should be_success }
    it { should render_template('projects/_form') }

    it 'has a default URL example' do
      subject
      response.body.should have_field('project_url_addresses',
                                      with: 'http://www.example.com/')
    end

    it 'has two default width examples' do
      subject
      response.body.should have_field('project_viewport_widths',
                                      with: "320\n1200")
    end
  end

  describe '#edit' do
    let(:project)   { create :project }
    let!(:viewport) { create :viewport, project: project }
    let!(:url)      { create :url, project: project }

    subject do
      get :edit, id: project.to_param
      response
    end

    it { should be_success }
    it { should render_template('projects/_form') }
    its(:body) { should include project.name }
    its(:body) { should include viewport.width.to_s }
    its(:body) { should include url.address }
  end

  describe '#create' do
    context 'with valid params' do
      let(:params) do
        {
          name:            Random.rand(100_000).to_s,
          viewport_widths: "320\n1024",
          url_addresses:   "https://example1.com\nhttps://example2.com",
        }
      end

      subject do
        post :create, project: params
        response
      end

      it 'adds a Project' do
        expect { subject }.to change { Project.count }.by(1)
      end

      it 'creates viewports' do
        expect { subject }.to change { Viewport.count }.by(2)
      end

      it 'creates urls' do
        expect { subject }.to change { Url.count }.by(2)
      end
    end
  end

  describe '#update' do
    let!(:project) { create :project, :with_viewport, :with_url }
    let(:params) do
      {
        name:            name,
        viewport_widths: viewport_widths,
        url_addresses:   url_addresses,
      }
    end
    let(:name)            { project.name }
    let(:viewport_widths) { project.viewport_widths }
    let(:url_addresses)   { project.url_addresses }

    subject do
      post :update, project: params, id: project.to_param
      response
    end

    context 'with identical params' do
      it 'does not add a Project' do
        expect { subject }.to change { Project.count }.by(0)
      end

      it 'does not change viewports' do
        expect { subject }.to change { Viewport.count }.by(0)
      end

      it 'does not change urls' do
        expect { subject }.to change { Url.count }.by(0)
      end
    end

    context 'with different params' do
      context 'with an extra viewport width' do
        let(:viewport_widths) { project.viewport_widths += "\n9999" }

        it 'adds a viewport' do
          expect { subject }.to change { Viewport.count }.by(1)
        end
      end

      context 'with one less viewport width' do
        let(:viewport_widths) do
          project.viewports[0..-2].map(&:width).join("\n")
        end

        it 'removes a viewport' do
          expect { subject }.to change { Viewport.count }.by(-1)
        end
      end

      context 'with an extra url address' do
        let(:url_addresses) do
          project.url_addresses += "\nhttp://example.com"
        end

        it 'adds a url' do
          expect { subject }.to change { Url.count }.by(1)
        end
      end

      context 'with an extra url that is a duplicate except for whitespace' do
        # This does not seem to actually fail here in the specs when it should.
        let(:url_addresses) do
          project.url_addresses += "\n #{project.urls.last.address} "
        end

        it 'does not add a url' do
          expect { subject }.to change { Url.count }.by(0)
        end
      end

      context 'with one less url address' do
        let(:url_addresses) do
          project.urls[0..-2].map(&:address).join("\n")
        end

        it 'removes a url' do
          expect { subject }.to change { Url.count }.by(-1)
        end
      end
    end
  end

  describe '#destroy' do
    let!(:project) { create :project }

    subject do
      delete :destroy, id: project.to_param
      response
    end

    it 'removes the project' do
      expect { subject }.to change { Project.all.count }.by(-1)
    end
  end
end
