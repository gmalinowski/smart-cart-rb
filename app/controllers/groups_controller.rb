
class GroupsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: [ :show, :new, :create, :destroy ]

  def show
    @group = Group.find(params[:id])
    authorize @group
  end
  def create
    @group = current_user.groups.new(group_params)
    authorize @group
    if @group.save
      redirect_to @group
    else
      render :new, status: :unprocessable_content
    end
  end
  def destroy
    @group = Group.find(params[:id])
    authorize @group
    if @group.destroy
      flash[:info] = "Group deleted"
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = "Group could not be deleted"
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    @group = current_user.groups.new
    authorize @group
  end

  private
  def group_params
    params.require(:group).permit(:name)
  end
end
