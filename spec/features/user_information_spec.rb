require 'rails_helper'

feature 'User can edit information' do
  let!(:user) { create :user }
  let!(:boulder) { create :location }
  let!(:detroit) { create :location, city: 'Detroit', state: 'MI' }

  before do
    login_as(user, :scope => :user)
    visit user_path(user)
  end

  scenario 'including location' do
    expect(user.location).to be_nil
    expect(page).to_not have_content 'Sign_in'
    click_on 'Edit My Profile'
    expect(page).to have_content 'Location'
    select 'Boulder, CO'
    click_on 'Submit'
    expect(user.reload.location).to eq boulder
    expect(page).to have_content user.location.city_state
  end

  scenario 'can choose other location' do
    click_on 'Edit My Profile'
    select 'Other'
    fill_in :user_zip_code, with: '12345'
    click_on 'Submit'
    expect(user.reload.location).to be_nil
    expect(user.zip_code).to eq '12345'
  end

  scenario 'clears zip code if they choose an existing location' do
    click_on 'Edit My Profile'
    select 'Other'
    fill_in :user_zip_code, with: '12345'
    click_on 'Submit'

    click_on 'Edit My Profile'
    select 'Detroit, MI'
    click_on 'Submit'
    expect(user.reload.location).to eq detroit
    expect(user.zip_code).to be_nil
  end

end
