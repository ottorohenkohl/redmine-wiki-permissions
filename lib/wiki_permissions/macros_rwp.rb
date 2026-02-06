module WikiPermissions
  module MacrosRwp
    def macro_include(obj, args)
      page = Wiki.find_page(args.first.to_s, project: @project)
      if page.present?
        unless User.current.has_permission?(@page)
          raise 'Access to page is denied'
        end
      end
      super
    end
  end
end
