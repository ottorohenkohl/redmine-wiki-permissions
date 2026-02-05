module WikiPermissions
  module SearchControllerRwp
    def index
      super

      return if @results.nil?

      @results.reject! do |result|
        result.is_a?(WikiPage) && !User.current.can_view?(result)
      end
    end
  end
end
