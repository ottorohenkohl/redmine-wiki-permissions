class CreateWikiPageUserPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_page_user_permissions do |t|
      t.integer :member_id
      t.integer :wiki_page_id
      t.integer :level
    end
  end
end
