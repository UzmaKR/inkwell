require 'spec_helper'

describe Occasion do

  
  let!(:user) {create(:user)}
  let!(:friend) {create(:friend)}
  let(:occasion) {build(:occasion)}

  it {should validate_presence_of(:name)}
  it {should validate_presence_of(:date)}
  it {should have_many(:orders)}
  it {should belong_to(:friend)}

  describe "#user" do
  	it "gets user for friend/occasion pair" do
  		occasion.stub_chain(:friend, :user).and_return(user)
  		occasion.user.should eq(user)
  	end
  end
  
  describe "when first creating an occasion" do
  	before { occasion.stub_chain(:friend, :user, :id).and_return(user.id) }

  	context "without a friend" do
  		it "creates a friend" do
  			occasion.should_receive(:friend).and_return(false)
  			expect {occasion.save}.to change{Friend.count}.by(1)
  		end
  	end

  	context "with a friend" do
  		
  			let!(:occasion2) {build(:occasion, friend_name: "Polly", user_id: 89)}
  			let!(:friend2) {create(:friend, name: "Polly", user_id: 89)}
 
  		it "it will not create a friend" do
  			occasion2.stub_chain(:friend, :user, :id).and_return(user.id)
  			occasion2.should_receive(:friend).and_return(false)
  			Friend.should_receive(:where).and_return([friend2])
  			expect {occasion2.save}.to change{Friend.count}.by(0)
  		end
  	end


  	context "#create_order" do

  		it "an order gets created" do
  			expect {occasion.save}.to change{Order.count}.by(1)
  		end

  		it "user and occasion must already exist for this order" do
  			occasion.save
  			order = Order.all.first
  			(order.user_id).should_not eql(nil)
  			(order.occasion_id).should_not eql(nil)
  		end
  	end
  end

  describe "::parse_birthday" do
  	before do 
  		@birthday = "10/22"
  		@formatted_date = Date.strptime("22-10","%d-%m")
  	end
  	it "will return birthday as Date object" do
  		(Occasion.parse_birthday(@birthday)).should be_an_instance_of(Date)
  	end
  	it "will return correctly formated Date" do
  		(Occasion.parse_birthday(@birthday)).should eql(@formatted_date)
  	end
  end

  describe "#upcoming?" do
  	
  	it "true if occasion date is within 2 months of today's date" do
  		date = Date.today + 20.days
  		upcoming_occasion = build(:occasion, date: date)
  		(upcoming_occasion.upcoming?).should be_true
  	end
  	it "false if occasion date is more than 2 months from today's date" do
  		date = Date.today + 90.days
  		upcoming_occasion = build(:occasion, date: date)
  		(upcoming_occasion.upcoming?).should be_false
  	end
  end

  describe "#today?" do
  	it "returns true if occasion date is today" do
  		date = Date.today
  		todays_occasion = build(:occasion, date: date)
  		(todays_occasion.today?).should be_true
  	end
  	it "returns false if occasion date is not today" do
  		date = Date.today + 10.days
  		future_occasion = build(:occasion, date: date)
  		(future_occasion.today?).should be_false
  	end
  end


 

end
