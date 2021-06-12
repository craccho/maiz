require 'spec_helper'

describe 'test', type: :feature, js: true do
  before do
    Capybara.app_host = "http://foo:bar@#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/"
  end
  it "should basic auth" do
    visit '/test'
    expect(page).to have_content 'me'
  end
end
