require "rails_helper"

describe Project do
  subject { FactoryBot.build(:project) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:default_channel) }
  it { should validate_presence_of(:github_url) }
  it { should validate_uniqueness_of(:github_url) }

  it { should belong_to(:default_channel) }
end
