require File.dirname(__FILE__) + '/spec_helper'

describe Romey do
  include Rack::Test::Methods

  def app
    @app ||= Romey
  end

  describe '#root' do
    it 'should return success' do
      get '/'
      p last_response
      last_response.should be_ok
    end
  end
end
