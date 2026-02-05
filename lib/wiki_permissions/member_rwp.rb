module WikiPermissions
  module MemberRwp
    def self.prepended(base)
      base.class_eval do
        has_many :wiki_page_user_permissions, dependent: :destroy
      end
    end
  end
end
