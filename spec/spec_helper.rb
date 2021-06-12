require 'capybara'
require 'capybara/rspec'
require_relative '../maiz'

Capybara.app = Maiz
Capybara.server = :puma
Capybara.javascript_driver = :selenium_chrome_headless
