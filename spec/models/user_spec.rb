require 'spec_helper'

describe User do
  
  let!(:user) { create(:user) }
  
  it { should validate_presence_of(:email)}
  it { should validate_presence_of(:encrypted_password)}
  it { should validate_uniqueness_of(:email)}
  it { should validate_confirmation_of(:password)}

  it { should have_many(:friends) }
  it { should have_many(:occasions) }
  it { should have_many(:orders) }
  it { should have_many(:authentications)}

  it "should have no friends on creation" do
    expect(user.friends.count).to be 0
  end

  describe "#password_required?" do

    it "password required if password is blank" do
      user1 = build(:user, password: " " )
      expect(user1.password_required?).to eq(true)
    end

    it "password not required if password not blank" do
      expect(user.password_required?).to eq(false)
    end
  end

  describe "#name" do
    it "should return first name and last name combined" do
      expect(user.name).to eq(user.first_name + " " + user.last_name)
    end   
  end

  describe "order methods for User class" do   
    before :each do
      @order1 = double(created_at: 1.day.ago, status: "no_card")
      @order2 = double(created_at: 2.days.ago, status: "no_card")
      @order3 = double(created_at: 3.days.ago, status: "in_cart")
      @occasion1 = double()
      @occasion2 = double()
      
      
    end

    it "#orders_without_cards" do
      user.should_receive(:orders).and_return([@order1,@order2,@order3])
      @order1.should_receive(:occasion).and_return(@occasion1)
      @order2.should_receive(:occasion).and_return(@occasion2)
      @order3.should_not_receive(:occasion)

      expect(user.orders_without_cards).to eq([@occasion1,@occasion2])
    end

    it "#orders_in_cart" do
      user.should_receive(:orders).and_return([@order1,@order2,@order3])
      expect(user.orders_in_cart).to eq([@order3])
    end

    it "#orders_in_cart_total" do
      
      user.should_receive(:orders_in_cart).and_return([@order3])
      @order3.stub_chain(:card,:price).and_return(500)

      expect(user.orders_in_cart_total).to eq(500)
    end

    context "future and upcoming orders" do

      before :each do 
        user.should_receive(:orders).and_return([@order1,@order2,@order3])
        @order1.should_receive(:upcoming?).and_return(false)
        @order2.should_receive(:upcoming?).and_return(true)
        @order3.should_receive(:upcoming?).and_return(false)
        
      end

      it "#future_orders" do
       
        @order1.should_receive(:event_date).and_return(Date.today + 65.days)
        @order2.should_not_receive(:event_date)
        @order3.should_receive(:event_date).and_return(Date.today + 62.days)
      
        expect(user.future_orders).to eq([@order1,@order3])
      end

      it "#upcoming_orders" do
       
        @order1.should_not_receive(:event_date)
        @order2.should_receive(:event_date).and_return(Date.today + 42.days)
        @order3.should_not_receive(:event_date)

        expect(user.upcoming_orders).to eq([@order2])
      end
    end
  end

  describe "facebook methods" do
    before :each do 
      @dummy_token = "dummy_access_token"
      @access_token = ACCESS_TOKEN
    end

    it "#facebook without block" do
      user.stub_chain(:authentications,:find_by_provider, :oauth_token).and_return(@dummy_token)
      api_instance = Koala::Facebook::API.new(@dummy_token)
      (user.facebook.class).should == api_instance.class
    end

    it "#facebook with a block" do
      user.stub_chain(:authentications,:find_by_provider, :oauth_token).and_return(@dummy_token)
      api_instance_string = "--- !ruby/object:Koala::Facebook::API\naccess_token: " + @dummy_token + "\n"
      (user.facebook { |fb| fb.to_yaml }).should eql(api_instance_string)
    end

    describe "#get_facebook_friends" do
      it "should return list of friends" do
        user.stub_chain(:authentications,:find_by_provider, :oauth_token).and_return(@access_token)
        
        VCR.use_cassette('user/get_facebook_friends', record: :new_episodes) do
          user.get_facebook_friends.first.keys.should eql(["name","birthday","id","picture"])
        end      
      end
    end

    describe "#authenticated_with_facebook?" do
      it "returns true if user facebook authentication has not expired" do
        user.stub_chain(:authentications, :find_by_provider).and_return(true)
        user.stub_chain(:authentications, :find_by_provider, :oauth_expires_at).and_return(Time.now + 2.days)
        
        expect(user.authenticated_with_facebook?).to be_true
      end

      it "returns false if user facebook authentication has expired" do
        user.stub_chain(:authentications, :find_by_provider).and_return(true)
        user.stub_chain(:authentications, :find_by_provider, :oauth_expires_at).and_return(Time.now - 2.days)

        expect(user.authenticated_with_facebook?).to be_false
      end

      it "returns false when user facebook authentication does not exist" do
        user.stub_chain(:authentications, :find_by_provider).and_return(false)

        expect(user.authenticated_with_facebook?).to be_false
      end

    end

    describe "#send_welcome_email" do
      it "calls UserMailer with the user object" do
        UserMailer.should_receive(:welcome_email).with(user)
        UserMailer.stub_chain(:welcome_email, :deliver)
        user.send_welcome_email
      end
    end

  end 



end
