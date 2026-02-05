Rails.configuration.to_prepare do
  WikiPage.prepend(WikiPermissions::WikiPageRwp) unless WikiPage.ancestors.include?(WikiPermissions::WikiPageRwp)
  WikiController.prepend(WikiPermissions::WikiControllerRwp) unless WikiController.ancestors.include?(WikiPermissions::WikiControllerRwp)
  SearchController.prepend(WikiPermissions::SearchControllerRwp) unless SearchController.ancestors.include?(WikiPermissions::SearchControllerRwp)
  User.prepend(WikiPermissions::UserRwp) unless User.ancestors.include?(WikiPermissions::UserRwp)
  Member.prepend(WikiPermissions::MemberRwp) unless Member.ancestors.include?(WikiPermissions::MemberRwp)
  Redmine::WikiFormatting::Macros::Definitions.prepend(WikiPermissions::MacrosRwp) unless Redmine::WikiFormatting::Macros::Definitions.ancestors.include?(WikiPermissions::MacrosRwp)

  if WikiController.respond_to?(:clear_action_methods!)
    WikiController.send(:clear_action_methods!)
  end
end

Rails.application.config.after_initialize do
  User.prepend(WikiPermissions::UserRwp) unless User.ancestors.include?(WikiPermissions::UserRwp)
  WikiPage.prepend(WikiPermissions::WikiPageRwp) unless WikiPage.ancestors.include?(WikiPermissions::WikiPageRwp)
  WikiController.prepend(WikiPermissions::WikiControllerRwp) unless WikiController.ancestors.include?(WikiPermissions::WikiControllerRwp)

  if WikiController.respond_to?(:clear_action_methods!)
    WikiController.send(:clear_action_methods!)
  end
end

Redmine::Plugin.register :redmine_wiki_permissions do
  name 'Wiki Permissions'
  author 'Otto Rohenkohl'
  description 'A Redmine Plugin for adding permissions to every Wiki Page'
  version '0.1.0'

  requires_redmine :version_or_higher => '6.0.0'
  
  project_module :wiki do
    permission :edit_wiki_permissions, { :wiki => [:permissions, :create_wiki_page_user_permissions, :update_wiki_page_user_permissions, :destroy_wiki_page_user_permissions] }
  end
end
