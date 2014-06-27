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
      expect(last_response).to be_ok
    end
    it 'should include the title' do
      get '/'
      expect(last_response.body).to match /handmade/i
    end
    it 'renders events' do
      get '/'
      expect(last_response.body).to have_tag('#events.panel')
    end
    it 'does not render events that are older than yesterday' do
      t = Time.now + (12000)
      5.times.each do
        EventResource.create( :title => gen_random_string, :starttime => t, :url => gen_random_string, :description => '')
        t -= (3600 * 24)
      end
      get('/')
      expect(last_response.body).to have_tag('.event')
    end
    it 'includes a description' do
      get('/')
      expect(last_response.body).to have_tag('meta', :with => {:name => 'description'})
    end
    it 'includes keywords' do
      get('/')
      expect(last_response.body).to have_tag('meta', :with => {:name => 'keywords'})
    end
  end

  describe 'authorized urls' do
    describe 'GET' do
      [ '/keywords', '/baby/upload','/baby/uploads', '/upload','/uploads', '/event', '/events' ].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          get endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'whatever','whatever'
          get endpoint
          expect(last_response).to be_ok
        end
      end
    end
    describe 'POST' do
      [ ['/event/update_attr', :id => '23_url', :value => 'url'],
        ['/event', :event => {:starttime => 'yo'}]
      ].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          post *endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'whatever','whatever'
          post *endpoint
          expect(last_response).to be_ok
        end
      end
    end
  end

  describe '#keywords' do
    before do
      KeywordResource.new(:keyword => 'yo1', :id => 12).save
      KeywordResource.new(:keyword => 'yo2', :id => 14).save
      KeywordResource.new(:keyword => 'yo yo3', :id => 15).save
    end

    it "has a 'create new' link" do
      authorize 'whatever','whatever'
      get '/keywords'
      expect(last_response.body).to have_tag('.add_keywords form', :with => {:action=>'/keyword'})
      expect(last_response.body).to have_tag('.add_keywords input', :with => {:type=>'submit'})
    end

    it "shows a list of keywords" do
      authorize 'whatever','whatever'
      get '/keywords'
      expect(last_response.body).to have_tag('ul li.kw', :count => 3)
    end

    it "returns delete links for each image" do
      authorize 'whatever','whatever'
      get '/keywords'
      expect(last_response.body).to have_tag('ul li.kw div.del a', :with => {:href=>'/keyword/del/12'})
      expect(last_response.body).to have_tag('ul li.kw div.del a', :with => {:href=>'/keyword/del/14'})
    end
  end

  describe '#keyword' do
    it "shows a list of keywords" do
      authorize 'whatever','whatever'
      post '/keyword', :keyword => 'rock and roll'
      (KeywordResource.all.map(&:keyword).include? 'rock and roll').should be
      last_response.status.should == 302
    end
  end
  describe '#keyword/del' do
    it "shows a list of keywords" do
      authorize 'whatever','whatever'
      k = KeywordResource.new(:keyword => 'whatever')
      k.save
      (KeywordResource.all.map(&:keyword)).should include 'whatever'
      get "/keyword/del/#{k.id}"
      last_response.status.should == 302
      (KeywordResource.all.map(&:keyword)).should_not include 'whatever'
    end
  end

  describe "#uploads" do
    it "has a 'create new' link" do
      authorize 'whatever','whatever'
      get '/uploads'
          # ', :with => {:href=>'/upload']
      expect(last_response.body).to have_tag('a button', 'Add a new image')
    end

    it "shows a list of images" do
      expect(ImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                          double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/uploads'
      expect(last_response.body).to have_tag('ul li.uploaded_image', :count => 2)
    end

    it "returns images sorted by id descending" do
      expect(ImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                          double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/uploads'
      expect(last_response.body).to have_tag('ul li.uploaded_image img', :with => {:src=>'url1'})
      expect(last_response.body).to have_tag('ul li.uploaded_image img', :with => {:src=>'url2'})
    end
    it "returns delete links for each image" do
      expect(ImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                          double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/uploads'
      expect(last_response.body).to have_tag('.uploaded_image .del a', :with => {:href=>'/pic/del/12'})
      expect(last_response.body).to have_tag('.uploaded_image .del a', :with => {:href=>'/pic/del/10'})
    end
  end

  describe "#baby/uploads" do
    it "has a 'create new' link" do
      authorize 'whatever','whatever'
      get '/baby/uploads'
      expect(last_response.body).to have_tag('a button', 'Add a new image')
    end

    it "shows a list of images" do
      expect(BabyImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                              double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/baby/uploads'
      expect(last_response.body).to have_tag('ul li.uploaded_image', :count => 2)
    end

    it "returns images sorted by id descending" do
      expect(BabyImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                              double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/baby/uploads'
      expect(last_response.body).to have_tag('ul li.uploaded_image img', :with => {:src=>'url1'})
      expect(last_response.body).to have_tag('ul li.uploaded_image img', :with => {:src=>'url2'})
    end
    it "returns delete links for each image" do
      expect(BabyImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                              double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]
      authorize 'whatever','whatever'
      get '/baby/uploads'
      expect(last_response.body).to have_tag('ul li.uploaded_image div a', :with => {:href=>'/baby/pic/del/12'})
      expect(last_response.body).to have_tag('ul li.uploaded_image div a', :with => {:href=>'/baby/pic/del/10'})
    end
  end

  describe '#event' do
    it 'renders a form for event input' do
      authorize 'whatever','whatever'
      get '/event'
      expect(last_response.body).to have_tag('input#event_title')
    end
    [ :title, :address, :starttime, :endtime, :url].each do |fld|
      it "form has an input for #{fld}" do
        authorize 'whatever','whatever'
        get '/event'
        expect(last_response.body).to have_tag("input#event_#{fld.to_s}")
      end
    end
    it "form has a textarea for description" do
      authorize 'whatever','whatever'
      get '/event'
      expect(last_response.body).to have_tag("textarea#event_description")
    end
  end

  describe '#events' do
    it "renders all events" do
      authorize 'whatever','whatever'
      post '/event', { :event => {:title => 'yo1', 'description' => 'stuff' , :starttime => Time.now + 20000 }  }
      post '/event', { :event => {:title => 'yo2', 'description' => 'stuff' , :starttime => Time.now + 30000 }  }
      get '/events'
      expect(last_response.body).to have_tag('ul li.event', :count => 2)
      expect(last_response.body).to have_tag('ul li.event .title', 'yo2')
      expect(last_response.body).to have_tag('ul li.event .title', 'yo1')
    end
  end

  describe 'POST#event' do
    it "creates a new event" do
      authorize 'whatever','whatever'
      precount = EventResource.count
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff', :starttime => Time.now + 10000 }  }
      (EventResource.count - precount).should == 1
    end
    it "redirects to events list page" do
      authorize 'whatever','whatever'
      post '/event', { :event => {:title => 'yo', 'description' => 'stuff' , :starttime => Time.now + 20000 }  }
      last_response.status.should == 302
    end
  end

  describe '#events/update_attr' do
    it "updates event attribute" do
      authorize 'whatever','whatever'

      ev = EventResource.create(:title => 'yo', :starttime => Time.now)
      binding.pry
      _id = "%d_title" % ev.id
      params = { :id => _id, :value => 'the new title' }
      post '/event/update_attr', params
      expect(last_response.body).to eql 'the new title'
      binding.pry
      fetched = EventResource.get(ev.id)
      fetched.title.should == 'the new title'
    end
    it "updates event endtime using chronic parsing" do
      authorize 'whatever','whatever'

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
      mock_event = double(EventResource)
      expect(mock_event).to receive(:destroy)
      expect(EventResource).to receive(:get).with('19').and_return( mock_event )
      authorize 'whatever','whatever'
      get "/event/del/19"
    end

    it "redirects to events" do
      authorize 'whatever','whatever'
      get "/event/del/4"
      last_response.status.should == 302
    end
  end

  describe "#pic/del" do
    it "removes the desired image" do
      mock_event = double(ImageResource)
      expect(mock_event).to receive(:destroy)
      expect(ImageResource).to receive(:get).with('19').and_return( mock_event )
      authorize 'whatever','whatever'
      get "/pic/del/19"
    end

    it "redirects to uploads" do
      authorize 'whatever','whatever'
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
      expect(ImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                          double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]

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
      expect(BabyImageResource).to receive(:all).and_return [ double("MockFile", :file => double('MockUpload', :url => 'url1'), :id => 10),
                                                              double("MockFile", :file => double('MockUpload', :url => 'url2'), :id => 12) ]

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
