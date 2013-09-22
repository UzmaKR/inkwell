require 'spec_helper'

describe Tag do
  
  it { should validate_presence_of(:name)}
  it { should have_and_belong_to_many(:cards) }

  describe "#to_param" do
  	before { @mytag = build(:tag, name: "a tag") }

  	it "should return tag name instead of tag id " do
  		@mytag.to_param.should eq("#{@mytag.name.parameterize}")
  	end

  end

end