module WikiPermissions
  module WikiControllerRwp
    def self.prepended(base)
      base.class_eval do
        helper_method :include_module_wiki_permissions?
        before_action :rwp_check_wiki_permissions, only: %i[show edit update]
        before_action :find_existing_page, only: %i[permissions create_wiki_page_user_permissions update_wiki_page_user_permissions destroy_wiki_page_user_permissions]
      end
    end

    def authorize(ctrl = params[:controller], action = params[:action])
      allowed = User.current.allowed_to?({ controller: ctrl, action: action }, @project, { params: params })
      allowed ? true : deny_access
    end

    def permissions
      @wiki_page_user_permissions = WikiPageUserPermission.where(wiki_page_id: @page.id)

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
      return redirect_back(fallback_location: { action: 'permissions', id: @page.title, project_id: @page.project }) if params[:wiki_page_user_permission].blank?

      params[:wiki_page_user_permission].each_pair do |index, level|
        permission = WikiPageUserPermission.find(index.to_i)
        permission.update(level: level.to_i)
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
      when 'show'
        deny_access unless User.current.has_permission?(@page) || User.current.can_view?(@page)
      when 'edit', 'update'
        return if @page.new_record?

        deny_access unless User.current.has_permission?(@page) || User.current.can_edit?(@page)
      end
    end

    def wiki_page_user_permission_params
      params.require(:wiki_page_user_permission).permit(:member_id, :wiki_page_id, :level)
    end
  end
end
