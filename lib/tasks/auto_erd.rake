
if Rails.env.development?
  Rake::Task["db:migrate"].enhance do
    Rake::Task["erd"].invoke
  end

  Rake::Task["db:rollback"].enhance do
    Rake::Task["erd"].invoke
  end
end