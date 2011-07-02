require File.dirname(__FILE__) + '/spec_helper'
require 'mime/types'

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

  describe 'authorized urls' do
    [ '/upload','/uploads' ].each do |endpoint|
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
      last_response.body.should have_tag('ul li.uploaded_image div a[@href=/del/12]')
      last_response.body.should have_tag('ul li.uploaded_image div a[@href=/del/10]')
    end
  end

  describe "#del" do
    it "removes the desired image" do
      mock_image = mock(ImageResource)
      mock_image.expects(:destroy)
      ImageResource.expects(:find).with('10').returns( mock_image )
      authorize 'jennymey','jonnlovesjenn'
      get "/del/19" 
    end

    it "redirects to uploads" do
      authorize 'jennymey','jonnlovesjenn'
      get "/del/1"
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
