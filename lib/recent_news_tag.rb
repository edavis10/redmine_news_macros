# Display recent news.  Examples:
#
#   !{{recent_news}}
#   ...A box showing last 3 news items for all projects
#
#   !{{recent_news(10)}}
#   ...A box showing last 10 news items for all projects
#
#   !{{recent_news(10, 123)}}
#   ...A box showing last 10 news items for project 123
#
#   !{{recent_news(10, 'the-identifier')}}
#   ...A box showing last 10 news items for the project with the identifier of 'the-identifier'
#
#   !{{recent_news(10, 'Little Stream Software')}}
#   ...A box showing last 10 news items for the project named 'Little Stream Software'
class RecentNewsTag < ChiliProject::Liquid::Tags::Base
  def initialize(tag_name, markup, tokens)
    super
    if markup.present?
      tag_args = markup.split(',')
      @count = tag_args.first.to_i if tag_args.first.present?
      @project_id = tag_args[1].strip if tag_args[2].present?
    end
    @count ||= 3
  end

  def render(context)
    if @project_id.present?
      project = Project.visible.find_by_id(@project_id)
      project ||= Project.visible.find_by_identifier(@project_id)
      project ||= Project.visible.find_by_name(@project_id)
      return '' if project.nil?

      if User.current.allowed_to?(:view_news, project)
        news = project.news.all(:limit => @count, :order => "#{News.table_name}.created_on DESC")
      else
        return ''
      end
    else
      news = News.latest(User.current, @count)
    end
    context.registers[:view].render :partial => 'recent_news/list', :locals => {:news => news}
  end
  
  
end

Liquid::Template.register_tag('recent_news', RecentNewsTag)
ChiliProject::Liquid::Legacy.add('recent_news', :tag)
