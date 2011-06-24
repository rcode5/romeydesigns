require File.dirname(__FILE__) + '/spec_helper'

describe Romey do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe '#root' do
    it 'should return success' do
      get '/'
      last_response.should be_success
    end
  end
end
