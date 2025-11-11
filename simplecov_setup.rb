return if defined?(SimpleCov) && SimpleCov.running

require 'simplecov'

SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum = ENV['SIMPLECOV_MINIMUM_COVERAGE']
  minimum_coverage minimum.to_i if minimum
end
