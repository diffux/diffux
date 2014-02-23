class AddUserAgentToViewports < ActiveRecord::Migration
  def change
    # I'm using :text here, according to the internets user-agent strings can
    # get quite long:
    # http://stackoverflow.com/questions/654921/how-big-can-a-user-agent-string-get
    add_column :viewports, :user_agent, :text
  end
end
