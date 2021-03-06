class Admin::UsersController < Admin::ApplicationController
  before_action :find_user, only: [:show, :edit, :update, :destroy, :archive]
  before_action :find_projects, only: [:new, :create, :edit, :update]

  def index
    @users = User.excluding_archived.order(:email)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    build_roles_for(@user)

    if @user.save
      flash[:notice] = "User has been created."
      redirect_to admin_users_path
    else
      flash.now[:alert] = "User has not been created."
      render "new"
    end
  end

  def edit
  end

  def update
    # Remove blank passwords from the user paramaters. A blank password is
    # interpreted as "don't change password."
    if params[:user][:password].blank?
      params[:user].delete(:password)
    end

    User.transaction do
      @user.roles.clear
      build_roles_for(@user)

      if @user.update(user_params)
        flash[:notice] = "User has been updated."
        redirect_to admin_users_path
      else
        flash.now[:alert] = "User has not been updated."
        render "edit"
        raise ActiveRecord::Rollback
      end
    end
  end

  def archive
    if @user == current_user
      flash[:alert] = "You cannot archive yourself!"
    else
      @user.archive
      flash[:notice] = "User has been archived."
    end

    redirect_to admin_users_path
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :admin)
    end

    def find_user
      @user = User.find(params[:id])
    end

    def find_projects
      @projects = Project.order(:name)
    end

    def build_roles_for(user)
      role_date = params.fetch(:roles, [])
      role_date.each do |project_id, role_name|
        if role_name.present?
          user.roles.build(project_id: project_id, role: role_name)
        end
      end
    end
end
