require 'test_helper'

class RecentNewsMacroTest < ActionController::IntegrationTest
  def setup
    generate_user_as_project_manager
    @project.reload
    @project2 = Project.generate!(:is_public => false)
    User.add_to_project(@user, @project2, @role)
    News.generate!(:project => @project, :title => 'First')
    News.generate!(:project => @project, :title => 'Second')
    News.generate!(:project => @project2, :title => 'Third')
    News.generate!(:project => @project, :title => 'Fourth')
    
  end
  
  context "for a user without permission to see news items" do
    should "not see any items" do
      # Setup wiki page
      login_as
      visit_project(@project)
      click_link 'Wiki'
      assert_response :success

      fill_in 'content[text]', :with => "{{recent_news}}"
      click_button 'Save'
      assert_response :success
      click_link 'Sign out'
      
      @user2 = User.generate!(:login => 'nopermissions', :password => 'nopermissions', :password_confirmation => 'nopermissions')
      @limited_role = Role.generate!(:permissions => [:view_wiki_pages # No view news
                                                     ])
      User.add_to_project(@user2, @project, @limited_role)

      login_as 'nopermissions', 'nopermissions'
      visit_project(@project)
      click_link 'Wiki'
      assert_response :success

      assert has_content?('First')
      assert has_content?('Second')
      assert has_no_content?('Third') # other project
      assert has_content?('Fourth')
      assert has_no_content?('{{recent_news')
    end
    
  end

  context "for a user with permission to see news items" do
    should "see a list of news items on the wiki" do
      
      login_as
      visit_project(@project)
      click_link 'Wiki'
      assert_response :success

      fill_in 'content[text]', :with => "{{recent_news}}"
      click_button 'Save'
      assert_response :success

      assert find(:css, 'div.news')
      assert find(:css, 'div.news')
      assert find(:css, 'div.news')
      assert has_no_content?('First')
      assert has_content?('Second')
      assert has_content?('Third')
      assert has_content?('Fourth')
      assert has_no_content?('{{recent_news')
      
    end
    
  end
end
