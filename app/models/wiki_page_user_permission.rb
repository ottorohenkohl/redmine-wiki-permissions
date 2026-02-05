class WikiPageUserPermission < ActiveRecord::Base
  belongs_to :member, optional: true
  belongs_to :wiki_page

  def user
    member&.user
  end
end
