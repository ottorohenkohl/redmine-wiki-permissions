module WikiPermissions
  module WikiControllerRwp
    def self.prepended(base)
      base.class_eval do
        helper_method :include_module_wiki_permissions?
        before_action :rwp_find_page_for_actions, only: %i[rename destroy history annotate destroy_version]
        before_action :rwp_check_wiki_permissions, only: %i[show edit update rename destroy history annotate destroy_version]
        before_action :rwp_check_wiki_permissions_admin, only: %i[permissions create_wiki_page_user_permissions update_wiki_page_user_permissions destroy_wiki_page_user_permissions]
        before_action :find_existing_page, only: %i[permissions create_wiki_page_user_permissions update_wiki_page_user_permissions destroy_wiki_page_user_permissions]
      end
    end

    def authorize(ctrl = params[:controller], action = params[:action])
      allowed = User.current.allowed_to?({ controller: ctrl, action: action }, @project, { params: params })
      allowed ? true : deny_access
    end

    def permissions
      @wiki_page_user_permissions = WikiPageUserPermission.where(wiki_page_id: @page.id).where.not(member_id: nil)

      render template: 'wiki/edit_permissions'
    end

    def create_wiki_page_user_permissions
      @wiki_page_user_permission = WikiPageUserPermission.new(wiki_page_user_permission_params)

      if @wiki_page_user_permission.save
        redirect_to action: 'permissions', id: @page.title, project_id: @page.project
      else
        render action: 'new'
      end
    end

    def update_wiki_page_user_permissions
      if params[:wiki_page_default_permission].present?
        level = params[:wiki_page_default_permission][:level].to_i

        if level < 0
          WikiPageUserPermission.where(wiki_page_id: @page.id, member_id: nil).destroy_all
        else
          default_permission = WikiPageUserPermission.find_or_initialize_by(wiki_page_id: @page.id, member_id: nil)
          default_permission.update(level: level)
        end
      end

      if params[:wiki_page_user_permission].present?
        params[:wiki_page_user_permission].each_pair do |index, level|
          permission = WikiPageUserPermission.find(index.to_i)
          permission.update(level: level.to_i)
        end
      end

      redirect_back(fallback_location: { action: 'permissions', id: @page.title, project_id: @page.project })
    end

    def destroy_wiki_page_user_permissions
      WikiPageUserPermission.find(params[:permission_id]).destroy
      redirect_back(fallback_location: { action: 'permissions', id: @page.title, project_id: @page.project })
    end

    def include_module_wiki_permissions?
      @page&.project&.enabled_modules&.any? { |enabled_module| enabled_module.name == 'wiki' }
    end

    private

    def rwp_check_wiki_permissions
      return if @page.nil?

      case action_name
      when 'show', 'history', 'annotate'
        deny_access unless User.current.has_permission?(@page) || User.current.can_view?(@page)
      when 'edit', 'update', 'rename', 'destroy', 'destroy_version'
        return if @page.new_record?

        deny_access unless User.current.has_permission?(@page) || User.current.can_edit?(@page)
      end
    end

    def rwp_check_wiki_permissions_admin
      return if @page.nil?

      deny_access unless User.current.can_edit_permissions?(@page)
    end

    def rwp_find_page_for_actions
      return if @page.present?
      return if @wiki.nil?

      page_identifier = params[:page] || params[:id] || params[:title]
      return if page_identifier.blank?

      @page = @wiki.pages.find_by(title: page_identifier) || WikiPage.find_by(wiki_id: @wiki.id, title: page_identifier)
    end

    def wiki_page_user_permission_params
      params.require(:wiki_page_user_permission).permit(:member_id, :wiki_page_id, :level)
    end
  end
end
