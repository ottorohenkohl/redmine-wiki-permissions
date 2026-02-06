module WikiPermissions
  module UserRwp
    def has_permission?(page)
      return true if admin
      return false if page.nil?

      project_id = page.project&.id
      return false if project_id.nil?

      member = Member.find_by(user_id: id, project_id: project_id)
      return false if member.nil?

      explicit_permission = WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: member.id)
      return false if explicit_permission.present?

      default_permission = WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: nil)
      default_permission.nil?
    end

    def user_permission_greater?(page, lvl)
      permission_level = wiki_page_permission_level(page)
      permission_level.present? && permission_level >= lvl
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

      if project.enabled_modules.any? { |enabled_module| enabled_module.name == 'wiki' } && action.is_a?(Hash) && action[:controller] == 'wiki'
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
          page_identifier = options[:params][:page] || options[:params][:id]
          wiki_page = page_identifier && WikiPage.find_by(wiki_id: project.wiki.id, title: page_identifier)

          if wiki_page
            permission_level = wiki_page_permission_level(wiki_page)

            unless permission_level.nil?
              return case action[:action]
                     when 'index'
                       permission_level > 0
                     when 'edit'
                       permission_level > 1
                     else
                       permission_level > 2
                     end
            end
          end
        end
      end

      super(action, project, options)
    end

    def wiki_page_permission_level(page)
      return 3 if admin
      return nil if page.nil?

      project_id = page.project&.id
      return nil if project_id.nil?

      as_member = Member.find_by(user_id: id, project_id: project_id)
      return nil if as_member.nil?

      explicit_permission = WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: as_member.id)
      return explicit_permission.level if explicit_permission.present?

      default_permission = WikiPageUserPermission.find_by(wiki_page_id: page.id, member_id: nil)
      default_permission&.level
    end
  end
end
