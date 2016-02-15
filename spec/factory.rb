FactoryGirl.define do
  factory :post, class: DummyApp::Post do
    skip_create

    sequence (:id)    { |n| n }
    sequence (:title) { |n| "Title for post ##{ n }" }
    sequence (:body)  { |n| "Body for post ##{ n }" }

    trait :with_author do
      association :author, factory: :user
    end

    trait :with_comments do
      comments []
      after :create do |post|
        2.times do
          post.comments << (create :comment)
        end
      end
    end
  end

  factory :comment, class: DummyApp::Comment do
    skip_create

    sequence (:id)   { |n| n }
    sequence (:body) { |n| "Body for comment ##{ n }" }
    association :user
  end

  factory :user, class: DummyApp::User do
    skip_create

    sequence (:id)   { |n| n }
    sequence (:name) { |n| "Name for user ##{ n }" }
  end
end