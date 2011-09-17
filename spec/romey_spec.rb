require File.dirname(__FILE__) + '/spec_helper'
require 'mime/types'

describe Romey do
  include Rack::Test::Methods

  def app
    @app ||= Romey
  end

  describe '#index' do
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
    it 'renders events' do
      get '/'
      last_response.should have_tag('#events.panel')
    end
    it 'does not render events that are older than yesterday' do
      mock_events = []
      t = Time.now
      5.times.each do |idx|
        mock_events << mock(:starttime => t, :id => idx)
        t -= (3600 * 24)
      end
      EventResource.stubs(:all => mock_events)
      get('/')
      last_response.should have_tag('.event', 1)
    end

  end

  describe 'authorized urls' do
    [ '/upload','/uploads', '/event', '/events' ].each do |endpoint|
      it "GET #{endpoint} responds error with no auth" do
        get endpoint
        last_response.status.should == 401
      end
      it "GET #{endpoint} responds ok with proper auth" do
        authorize 'jennymey','jonnlovesjenn'
        get endpoint
        last_response.should be_ok
      end
    end
  end

  describe "#uploads" do
    it "has a 'create new' link" do
      authorize 'jennymey','jonnlovesjenn'
      get '/uploads'
      last_response.body.should have_tag('a[@href=/upload] button', 'Add a new image')
    end

    it "shows a list of images" do
      ImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/uploads'
      last_response.body.should have_tag('ul li.uploaded_image', :count => 2)
    end
    
    it "returns images sorted by id descending" do
      ImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/uploads'
      last_response.body.should have_tag('ul li.uploaded_image img[@src=url1]')
      last_response.body.should have_tag('ul li.uploaded_image img[@src=url2]')
    end
    it "returns delete links for each image" do
      ImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/uploads'
      last_response.body.should have_tag('ul li.uploaded_image div a[@href=/pic/del/12]')
      last_response.body.should have_tag('ul li.uploaded_image div a[@href=/pic/del/10]')
    end
  end

  describe '#event' do
    it 'renders a form for event input' do
      authorize 'jennymey','jonnlovesjenn'
      get '/event'
      last_response.body.should have_tag('input#event_title')
    end
    [ :title, :address, :starttime, :endtime, :url].each do |fld|
      it "form has an input for #{fld}" do
        authorize 'jennymey','jonnlovesjenn'
        get '/event'
        last_response.body.should have_tag("input#event_#{fld.to_s}")
      end
    end
    it "form has a textarea for description" do
      authorize 'jennymey','jonnlovesjenn'
      get '/event'
      last_response.body.should have_tag("textarea#event_description")
    end
  end

  describe '#events' do
    it "renders all events" do
      pending
      EventResource.stubs(:all => [ mock(:title => 'whatever', :description => 'this event' , :starttime => Time.now),
                                    mock(:title => 'yo dude', :description => 'rock it', :starttime => Time.now) ])

      authorize 'jennymey','jonnlovesjenn'
      get '/events'
      last_response.body.should have_tag('ul li.event', 2)
      last_response.body.should have_tag('ul li.event', /yo dude/)
    end
  end

  describe 'POST#event' do
    it "creates a new event" do
      authorize 'jennymey','jonnlovesjenn'
      precount = EventResource.count
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff', :starttime => '10/11/2011 6:00pm' }  }
      (EventResource.count - precount).should == 1
    end
    it "redirects to events list page" do
      authorize 'jennymey','jonnlovesjenn'
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff' , :starttime => '10/11/2011 6:00pm' }  }
      last_response.status.should == 302
    end
  end

  describe '#pic/del' do
    it "removes the event" do
      mock_event = mock(EventResource)
      mock_event.expects(:destroy)
      EventResource.expects(:find).with('10').returns( mock_event )
      authorize 'jennymey','jonnlovesjenn'
      get "/event/del/19" 
    end

    it "redirects to events" do
      authorize 'jennymey','jonnlovesjenn'
      get "/event/del/4"
      last_response.status.should == 302
    end
  end

  describe "#pic/del" do
    it "removes the desired image" do
      mock_image = mock(ImageResource)
      mock_image.expects(:destroy)
      ImageResource.expects(:find).with('10').returns( mock_image )
      authorize 'jennymey','jonnlovesjenn'
      get "/pic/del/19" 
    end

    it "redirects to uploads" do
      authorize 'jennymey','jonnlovesjenn'
      get "/pic/del/1"
      last_response.status.should == 302
    end
  end

  describe 'xhr get#pics' do
    it "returns json" do
      get "/pics"
      last_response.content_type.should ==  MIME::Types.type_for('json').first
    end
    it "returns a list of all image resources as json" do
      get "/pics"
      ImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])

      j = JSON.parse(last_response.body)
      j.count.should == ImageResource.all.count
    end
  end
end
