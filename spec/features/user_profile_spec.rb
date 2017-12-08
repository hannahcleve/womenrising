require 'rails_helper'

describe 'user show page' do
  let(:location) { create :location }
  let!(:user) { create :user, :groupable, location: location }
  let!(:user_in_current_group) { create :user, :groupable, location: location }
  let!(:user_in_other_group) { create :user, :groupable }

  before do
    login_as(user, scope: :user)
    PeerGroup.generate_groups
  end

  it 'should be viewable by other users in current group' do
    visit user_path(user_in_current_group)
    expect(page).to have_content user_in_current_group.full_name
    expect(page).to_not have_content "Will you participate"
    expect(page).to_not have_content "Edit My Profile"
  end

  it 'should not be viewable by other users not in current group' do
    expect do
      visit user_path(user_in_other_group)
    end.to raise_error ActiveRecord::RecordNotFound
  end

  it 'should show other users in peer group' do
    visit user_path(user)
    expect(page).to have_content user_in_current_group.full_name
    expect(page).to_not have_content user_in_other_group.full_name
    expect(page).to have_content "Will you participate"
    expect(page).to have_content "Edit My Profile"
  end
end
