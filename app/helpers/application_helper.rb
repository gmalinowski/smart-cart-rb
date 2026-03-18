module ApplicationHelper
  def dock_item_active?(path)
    current_page?(path) ? "dock-active" : ""
  end
end
