require File.dirname(__FILE__) + '/spec_helper'
require 'mime/types'

LETTERS_PLUS_SPACE =  (75).times.map{|num| (48+num).chr}.reject{|c| (c =~ /[[:punct:]]/)}
def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end

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
      t = Time.now + (12000)
      5.times.each do
        EventResource.create( :title => gen_random_string, :starttime => t, :url => gen_random_string, :description => '')
        t -= (3600 * 24)
      end
      get('/')
      last_response.should have_tag('.event')
    end

  end

  describe 'authorized urls' do
    describe 'GET' do
      [ '/baby/upload','/baby/uploads', '/upload','/uploads', '/event', '/events' ].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          get endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'jennymey','jonnlovesjenn'
          get endpoint
          last_response.should be_ok
        end
      end
    end
    describe 'POST' do
      [ ['/event/update_attr', :id => '23_url', :value => 'url'],['/event', :event => {:starttime => 'yo'}]].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          post *endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'jennymey','jonnlovesjenn'
          post *endpoint
          last_response.should be_ok
        end
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

  describe "#baby/uploads" do
    it "has a 'create new' link" do
      authorize 'jennymey','jonnlovesjenn'
      get '/baby/uploads'
      last_response.body.should have_tag('a[@href=/baby/upload] button', 'Add a new image')
    end

    it "shows a list of images" do
      BabyImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                        mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/baby/uploads'
      last_response.body.should have_tag('ul li.uploaded_image', :count => 2)
    end
    
    it "returns images sorted by id descending" do
      BabyImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/baby/uploads'
      last_response.body.should have_tag('ul li.uploaded_image img[@src=url1]')
      last_response.body.should have_tag('ul li.uploaded_image img[@src=url2]')
    end
    it "returns delete links for each image" do
      BabyImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                    mock(:file => mock(:url => 'url2'), :id => 12) ])
      authorize 'jennymey','jonnlovesjenn'
      get '/baby/uploads'
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
      authorize 'jennymey','jonnlovesjenn'
      post '/event', { :event => {:title => 'yo1', 'description' => 'stuff' , :starttime => Time.now + 20000 }  }
      post '/event', { :event => {:title => 'yo2', 'description' => 'stuff' , :starttime => Time.now + 30000 }  }
      get '/events'
      last_response.body.should have_tag('ul li.event', :count => 2)
      last_response.body.should have_tag('ul li.event .title', /yo2/)
      last_response.body.should have_tag('ul li.event .title', /yo1/)
    end
  end

  describe 'POST#event' do
    it "creates a new event" do
      authorize 'jennymey','jonnlovesjenn'
      precount = EventResource.count
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff', :starttime => Time.now + 10000 }  }
      (EventResource.count - precount).should == 1
    end
    it "redirects to events list page" do
      authorize 'jennymey','jonnlovesjenn'
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff' , :starttime => Time.now + 20000 }  }
      last_response.status.should == 302
    end
  end

  describe '#events/update_attr' do
    it "updates event attribute" do
      authorize 'jennymey','jonnlovesjenn'

      ev = EventResource.create(:title => 'yo', :starttime => Time.now)
      _id = "%d_title" % ev.id
      params = { :id => _id, :value => 'the new title' }
      post '/event/update_attr', params
      last_response.body.should == 'the new title'
      fetched = EventResource.get(ev.id)
      fetched.title.should == 'the new title'
    end
    it "updates event endtime using chronic parsing" do
      authorize 'jennymey','jonnlovesjenn'

      ev = EventResource.create(:title => 'yo', :starttime => Time.now)
      _id = "%d_endtime" % ev.id
      params = { :id => _id, :value => 'Tomorrow at 11pm' }
      post '/event/update_attr', params
      fetched = EventResource.get(ev.id)
      fetched.endtime.should_not be_nil
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

  describe 'xhr get#baby/pics' do
    it "returns json" do
      get "/baby/pics"
      last_response.content_type.should ==  MIME::Types.type_for('json').first
    end
    it "returns a list of all image resources as json" do
      get "/baby/pics"
      BabyImageResource.stubs(:all => [ mock(:file => mock(:url => 'url1'), :id => 10),
                                        mock(:file => mock(:url => 'url2'), :id => 12) ])

      j = JSON.parse(last_response.body)
      j.count.should == BabyImageResource.all.count
    end
  end

  describe 'helpers' do
    describe '#truncate' do
      it 'leaves short strings alone' do
        str = gen_random_string(10)
        str.truncate.should == str
      end
      it 'truncates strings longer than 40 to 40 chars with ...' do
        str = gen_random_string(60)
        trunc = str.truncate
        (trunc =~ /\.{3}$/).should be
      end
      it 'truncates string to 10 given length 10' do
        str = gen_random_string(60)
        trunc = str.truncate(10)
        trunc.length.should == 10
        (trunc =~ /\.{3}$/).should be
      end
      it 'adds a custom prefix and truncates to 40' do
        str = gen_random_string(60)
        trunc = str.truncate(40, 'postfix')
        trunc.length.should == 40
        (trunc =~ /postfix$/).should be
      end
    end
  end
  
end
