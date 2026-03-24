
class GroupsController < ApplicationController
  before_action :authenticate_user!

  def create
    @group = current_user.groups.new(group_params)
    if @group.save
      redirect_to @group
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @group = Group.find(params[:id])
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
  end

  private
  def group_params
    params.require(:group).permit(:name)
  end
end
