require 'rails_helper'

RSpec.describe Group, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owner_id) }
  it { should belong_to(:owner).class_name('User') }

  it "should have many shopping lists"
  it "delete shopping lists when group is deleted"
end
