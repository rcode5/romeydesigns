require File.dirname(__FILE__) + '/spec_helper'

describe Romey do
  include Rack::Test::Methods

  def app
    @app ||= Romey
  end

  describe '#root' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/'
      last_response.should be_ok
    end
    it 'should include the title' do
      get '/'
      last_response.should match /handmade/i
    end
  end
end
