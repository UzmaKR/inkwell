require File.dirname(__FILE__) + '/../spec_helper'

describe Authentication do
  it "should be valid" do
    Authentication.new.should be_valid
  end

  describe "Omniauth authentication" do
  	let!(:authentication) { create(:authentication) }
  	let(:omniauth) { {provider: "facebook", uid: '725231096'} }
  	let(:newentry) {{provider: "facebook", uid: '111111111', credentials: {token: "abcd", expires_at: Time.now + 10.days}}}

  	it "returns user if authentication entry exits" do
  		expect {Authentication.from_omniauth(omniauth)}.to change{Authentication.count}.by(0)
  	end

  	it "creates new entry if user does not exist" do
  		oauth_hashobject = OmniAuth::AuthHash.new(newentry)
  		expect {Authentication.from_omniauth(oauth_hashobject)}.to change{Authentication.count}.by(1)
  	end
  end

  describe "Initialize user if oauth fails" do

  	let!(:newentry) {{provider: "facebook", uid: '111111111'}}
  	let!(:params) {{provider: "facebook", uid: '111111111'}}
  	
  	it "initializes a new Authentication object for user if session exists from request" do
  		session_hash = {}
  		session_hash["devise.user_attributes"] = OmniAuth::AuthHash.new(newentry)
  
  		(Authentication.new_with_session(params, session_hash)).should be_an_instance_of(Authentication)
  	end

  	xit "if session does not exist: BUG: No Authentication.new_with_session exists in Devise" do
  		session_hash={}
  		p Authentication.new_with_session(params, session_hash)
  	end


  end

  
end
