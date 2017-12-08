class UsersController < ApplicationController
  before_action :auth_user
  before_action :set_industries_and_interests, only: [:edit, :update]

  def show
    permitted_users = User.where(id: current_user.related_user_ids)
    @user = permitted_users.find(params[:id])
    @career_stages = MentorIndustryUser.career_stages
    @mentee_mentorships = Mentorship.mentored_by(@user).order(:created_at).last(3)
    @mentor_mentorships = Mentorship.mentoring(@user).order(:created_at).last(3)
  end

  def edit
    @user = current_user
    @industries = MentorIndustry.all
    @interests = User::TOP_3_INTERESTS
    @career_stages = MentorIndustryUser.career_stages

    MentorIndustry.all.each do |industry|
      if !@user.mentor_industry_ids.include?(industry.id)
        @user.mentor_industry_users.build(mentor_industry_id: industry.id)
      end
    end
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to user_path(current_user)
    else
      @industries = MentorIndustry.all
      @interests = User::TOP_3_INTERESTS
      @career_stages = MentorIndustryUser.career_stages

      MentorIndustry.all.each do |industry|
        if !@user.mentor_industry_ids.include?(industry.id)
          @user.mentor_industry_users.build(mentor_industry_id: industry.id)
        end
      end
      
      render 'edit'
    end
  end

  def participate
    @user = current_user
    @user.update(is_participating_this_month: true)

    action = :user_participating
    message  = "User id #{@user.id} is participating"
    SlackNotification.notify(action, message)

    redirect_to user_path(current_user)
  end

  def not_participate
    @user = current_user
    @user.update(is_participating_this_month: false)

    redirect_to user_path(current_user)
  end

  private

  def set_industries_and_interests
    @industries = User::PRIMARY_INDUSTRY
    @interests = User::TOP_3_INTERESTS
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :mentor,
      :mentor_limit,
      :primary_industry,
      :stage_of_career,
      :peer_industry,
      :current_goal,
      :location_id,
      :zip_code,
      {
        mentor_industry_users_attributes: [
          :name,
          :career_stage,
          :_destroy,
          :id,
          :mentor_industry_id
        ]
      },
      top_3_interests: []
    )
  end

  def policy_scope scope
    scope.viewable_by(current_user)
  end
end
