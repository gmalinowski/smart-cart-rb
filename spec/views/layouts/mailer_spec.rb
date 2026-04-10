
require 'rails_helper'

RSpec.describe "layouts/mailer.html.erb", type: :view do
  it "renders app name" do
    render
    expect(rendered).to match(t('app_name'))
  end

  it "renders app url" do
    render
    expect(rendered).to match(root_url)
    end
end
