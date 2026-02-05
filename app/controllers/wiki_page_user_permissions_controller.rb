class WikiPageUserPermissionsController < ApplicationController
  def destroy
    WikiPageUserPermission.find(params[:id]).destroy
    redirect_back(fallback_location: home_url)
  end
  
  def update
    params[:wiki_page_user_permission].each_pair do |index, level|
      permission = WikiPageUserPermission.find(index.to_i)
      permission.update(level: level.to_i)
    end
    redirect_back(fallback_location: home_url)
  end
end
