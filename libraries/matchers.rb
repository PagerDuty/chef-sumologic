if defined?(ChefSpec)
  def create_sumo_source(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('sumo_source', :create, resource_name)
  end

  def delete_sumo_source(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('sumo_source', :delete, resource_name)
  end
end
