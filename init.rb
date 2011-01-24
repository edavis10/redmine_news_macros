require 'redmine'

Redmine::Plugin.register :redmine_news_macros do
  name 'News Macros'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author_url 'http://www.littlestreamsoftware.com'
  description 'This plugin adds wiki macros for News items'
  version '0.1.0'



  Redmine::WikiFormatting::Macros.register do
    desc <<-EOHELP
Display recent news.  Examples:

  !{{recent_news}}
  ...A box showing last 3 news items for all projects

  !{{recent_news(10)}}
  ...A box showing last 10 news items for all projects

  !{{recent_news(10, 123)}}
  ...A box showing last 10 news items for project 123

  !{{recent_news(10, 'the-identifier')}}
  ...A box showing last 10 news items for the project with the identifier of 'the-identifier'

  !{{recent_news(10, 'Little Stream Software')}}
  ...A box showing last 10 news items for the project named 'Little Stream Software'
EOHELP
    macro :recent_news do |obj, args|
      count = args[0] || 3
      project_id = args[1]

      if project_id.present?
        project_id.strip!
        
        project = Project.visible.find_by_id(project_id)
        project ||= Project.visible.find_by_identifier(project_id)
        project ||= Project.visible.find_by_name(project_id)
        return '' if project.nil?

        if User.current.allowed_to?(:view_news, project)
          news = project.news.all(:limit => count, :order => "#{News.table_name}.created_on DESC")
        else
          return ''
        end
      else
        news = News.latest(User.current, count)

      end

      render :partial => 'recent_news/list', :locals => {:news => news}
    end
  end
end
