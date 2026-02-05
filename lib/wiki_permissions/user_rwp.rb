module WikiPermissions
  module UserRwp
    def not_has_permission?(page)
      return true if page.nil?
      return true if admin

      project_id = page.project&.id
      return true if project_id.nil?

      member = Member.find_by(user_id: id, project_id: project_id)
      return true if member.nil?

      WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: member.id).nil?
    end

    def user_permission_greater?(page, lvl)
      return true if admin
      return false if page.nil?

      project_id = page.project&.id
      return false if project_id.nil?

      as_member = Member.find_by(user_id: id, project_id: project_id)
      return false if as_member.nil?

      wpup = WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: as_member.id)
      wpup.present? && wpup.level >= lvl
    end

    def can_edit?(page)
      user_permission_greater?(page, 2)
    end

    def can_edit_permissions?(page)
      user_permission_greater?(page, 3)
    end

    def can_view?(page)
      user_permission_greater?(page, 1)
    end

    def allowed_to?(action, project, options = {})
      return super(action, project, options) if project.nil? || project.wiki.nil?

      if project.enabled_modules.any? { |enabled_module| enabled_module.name == 'wiki' } &&
         action.is_a?(Hash) && action[:controller] == 'wiki'
        return true if User.current&.admin

        guarded_actions = %w[
          index
          edit
          permissions
          create_wiki_page_user_permissions
          update_wiki_page_user_permissions
          destroy_wiki_page_user_permissions
        ]

        if guarded_actions.include?(action[:action]) && options[:params].present?
          wiki_page = WikiPage.find_by(wiki_id: project.wiki.id, title: options[:params][:page])
          if wiki_page
            member = Member.find_by(user_id: User.current.id, project_id: project.id)
            permission = member && WikiPageUserPermission.find_by(member_id: member.id, wiki_page_id: wiki_page.id)
            if permission
              return case action[:action]
                     when 'index'
                       permission.level > 0
                     when 'edit'
                       permission.level > 1
                     else
                       permission.level > 2
                     end
            end
          end
        end
      end

      super(action, project, options)
    end
  end
end
