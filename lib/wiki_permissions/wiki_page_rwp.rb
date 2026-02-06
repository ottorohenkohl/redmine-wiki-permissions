module WikiPermissions
  module WikiPageRwp
    def self.prepended(base)
      base.class_eval do
        has_many :permissions, class_name: 'WikiPageUserPermission', dependent: :destroy
        after_create :role_creator
      end
    end

    def visible?(user = User.current)
      allowed = super(user)

      return false unless allowed

      rwp_page_visible?(user)
    end

    def rwp_page_visible?(user)
      user.present? && user.can_view?(self)
    end

    def leveled_permissions(level)
      WikiPageUserPermission.where(wiki_page_id: id, level: level)
    end

    def default_permission
      permissions.find_by(member_id: nil)
    end

    def users_without_permissions
      project.users - users_with_permissions
    end

    def users_with_permissions
      users = []

      WikiPageUserPermission.where(wiki_page_id: id).each do |permission|
        user = permission.user
        users << user if user
      end

      users
    end

    def members_without_permissions
      project.members - members_with_permissions
    end

    def members_with_permissions
      members_wp = []

      permissions.each do |permission|
        member = permission.member
        members_wp << member if member
      end

      members_wp
    end

    private
    def role_creator
      member = wiki.project.members.find_by(user_id: User.current.id)

      return if member.nil?

      WikiPageUserPermission.create(wiki_page_id: id, level: 3, member_id: member.id)
    end
  end
end
