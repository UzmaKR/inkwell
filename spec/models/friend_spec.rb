require 'spec_helper'

describe Friend do
  
  let!(:friend) {create(:friend)}
  let(:occasion) {create(:occasion)}
  let!(:user) {create(:user)}

  it { should have_many(:occasions) }

  it "should have no occasions on creation" do
    expect(friend.occasions.count).to be 0
  end

  it { should belong_to(:user) }

  describe "validate uniqueness of friend name" do
  		let(:friend2) {create(:friend, user_id: user.id)}
  	context "friend already exists for user" do
  		it "should raise an error" do
  			expect {create(:friend, name: friend2.name, user_id: user.id)}.to raise_error(ActiveRecord::RecordInvalid)
  		end
  	end
  end


  describe "::add_fb_friend" do
  	context "friend does exist" do 
  		let!(:friend2) {create(:friend, user_id: user.id)}
  		
  		before do
  			@params={ name: friend2.name }
  		end
  		it "will return the friend in database" do
  			expect {Friend.add_fb_friend(user,@params)}.not_to change {Friend.count}
  		end
  	end

  	context "friend does not exist" do
  		before do
  			@params={name: friend.name, image_url: "www.example.com", birthday: "01/01" }
  		end
  		it "will create new friend in database" do
  			expect {Friend.add_fb_friend(user,@params)}.to change {Friend.count}.by(1)
  		end
  		it "will create new occasion if friend's birthday exists" do
  			expect {Friend.add_fb_friend(user,@params)}.to change {Occasion.count}.by(1)
  		end
  	end
  end

end
