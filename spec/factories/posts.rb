FactoryGirl.define do
  factory :post do
    user_name { Faker::Name.name }
    user_avatar { Faker::Avatar.image }
    lat { Faker::Address.longitude }
    lng { Faker::Address.latitude }
  end

end
