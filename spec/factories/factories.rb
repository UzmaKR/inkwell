def datetime_rand from = Time.now, to = Time.now + 6.months
  Time.at(from + rand * (to.to_f - from.to_f))
end

FactoryGirl.define do

  factory :admin do
    email "admin@inkwell.com"
    password "cardmaster"
  end

  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email Faker::Internet.email
    password "password"
    street_address Faker::Address.street_address
    city Faker::Address.city
    state Faker::Address.state_abbr
    zipcode Faker::Address.zip_code
  end


  factory :friend do
    name           Faker::Name.name
    street_address Faker::Address.street_address
    city           Faker::Address.city
    state          Faker::Address.state_abbr
    zipcode        Faker::Address.zip_code
  end

  factory :card do
     title Faker::Lorem.words(5)
     description Faker::Lorem.sentences(4)
     price Random.rand(400..600)
     inventory Random.rand(0..10)
  end

  factory :tag do
    name Faker::Lorem.word
  end

  factory :occasion do
    date {datetime_rand}
    name "Birthday"
    event_type_name ["birthday","anniversary"].sample
  end

  factory :order do
    sequence(:user_id) { |n| n }
    sequence(:occasion_id) { |n| n }
    sequence(:card_id) { |n| n }
    sequence(:created_at) {|n| }
    lead_time 604800
    status "in_cart"
  end
    
end
