require 'spec_helper'


describe Card do
  
  it { should validate_presence_of(:title)}
  it { should validate_presence_of(:description)}
  it { should validate_presence_of(:price)}
  it { should validate_presence_of(:inventory)}
  it { should have_many(:orders) }
  it { should have_many(:tags) }
  it { should have_many(:cards_tags) }

  it { should have_many(:photos) }
  it { should accept_nested_attributes_for(:cards_tags) }

  describe "#tag_names" do
  	before do
  		@card = build(:card) 
  		2.times { @card.tags << build(:tag) }
  	end

  	it "should return all tags for a card" do
  		expect(@card.tag_names).to eq("#{@card.tags.first.name}, #{@card.tags.last.name}")
  	end
  end

end
