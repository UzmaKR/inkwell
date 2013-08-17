require 'spec_helper'

describe User do
  
  let!(:user) {create(:user)}

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
      @user = build(:user, password: " " )
      expect(@user.password_required?).to eq(true)
    end

    it "password not required if password not blank" do
      expect(user.password_required?).to eq(false)
    end
  end

  #describe "#name" do

  #end

end
