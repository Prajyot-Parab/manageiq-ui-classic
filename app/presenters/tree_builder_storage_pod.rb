class TreeBuilderStoragePod < TreeBuilder
  private

  def tree_init_options
    {:lazy => true}
  end

  def root_options
    {
      :text    => t = _("All Datastore Clusters"),
      :tooltip => t
    }
  end

  # Get root nodes count/array for explorer tree
  def x_get_tree_roots(count_only)
    items = EmsFolder.where(:type => 'StorageCluster')
    if count_only
      items.size
    else
      items.map do |item|
        {
          :id            => item[:id],
          :tree          => "dsc_tree",
          :text          => item[:name],
          :icon          => "pficon pficon-folder-close",
          :tip           => item[:description],
          :load_children => true
        }
      end
    end
  end

  def x_get_tree_custom_kids(object, count_only)
    objects = EmsFolder.find_by(:id => object[:id])&.storages
    count_only_or_objects(count_only, objects || [], "name")
  end
end
