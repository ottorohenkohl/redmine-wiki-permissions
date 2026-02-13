module WikiPermissions
  module AttachmentsControllerRwp
    def read_authorize
      return true if wiki_page_attachment_allowed?

      super
    end

    def delete_authorize
      if wiki_page_attachment?
        return true if wiki_page_attachment_editable?

        return deny_access
      end

      super
    end

    def edit
      return deny_access if wiki_page_attachment? && !wiki_page_attachment_editable?

      super
    end

    def update
      return deny_access if wiki_page_attachment? && !wiki_page_attachment_editable?

      super
    end

    def update_all
      return deny_access if wiki_page_attachments_present? && !wiki_page_attachments_editable?

      super
    end

    private

    def wiki_page_attachment_allowed?
      return false unless wiki_page_attachment?

      container = @attachment.container
      User.current.can_view?(container) || User.current.has_permission?(container)
    end

    def wiki_page_attachment_editable?
      return false unless wiki_page_attachment?

      container = @attachment.container
      User.current.can_edit?(container) || User.current.can_edit_permissions?(container)
    end

    def wiki_page_attachment?
      return false unless @attachment

      @attachment.container.is_a?(WikiPage)
    end

    def wiki_page_attachments_present?
      wiki_page_attachments.any?
    end

    def wiki_page_attachments_editable?
      wiki_page_attachments.all? do |attachment|
        page = attachment.container
        User.current.can_edit?(page) || User.current.can_edit_permissions?(page)
      end
    end

    def wiki_page_attachments
      ids =
        if params[:attachment_ids].present?
          params[:attachment_ids]
        elsif params[:ids].present?
          params[:ids]
        elsif params[:attachments].present?
          params[:attachments].keys
        else
          []
        end

      Attachment.where(id: ids).select { |attachment| attachment.container.is_a?(WikiPage) }
    end
  end
end
