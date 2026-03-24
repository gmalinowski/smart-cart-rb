
module FoldersHelper
  TABS = { recent: "recent", groups: "groups", lists: "lists" }.freeze
  DEFAULT_TAB = TABS[:recent]

  def active_tab(tab)
    TABS.value?(tab) ? tab : DEFAULT_TAB
  end

  def default_tab
    TABS[:default]
  end

  def is_active?(active_tab, target_tab)
    puts "active_tab: #{active_tab}, target_tab: #{target_tab}"
    "checked" if active_tab == target_tab
  end
end
