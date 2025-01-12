class DialogLocalService
  def determine_dialog_locals_for_svc_catalog_provision(resource_action, target, finish_submit_endpoint)
    api_submit_endpoint = "/api/service_catalogs/#{target.service_template_catalog_id}/service_templates/#{target.id}"

    {
      :resource_action_id     => resource_action.id,
      :target_id              => target.id,
      :target_type            => target.kind_of?(ServiceTemplate) ? "service_template" : target.class.name.underscore,
      :real_target_type       => target.class.base_class.name,
      :dialog_id              => resource_action.dialog_id,
      :force_old_dialog_use   => false,
      :api_submit_endpoint    => api_submit_endpoint,
      :api_action             => "order",
      :finish_submit_endpoint => finish_submit_endpoint,
      :cancel_endpoint        => "/catalog/explorer",
      :open_url               => false
    }
  end

  def determine_dialog_locals_for_custom_button(obj, button_name, resource_action, display_options = {})
    submit_endpoint, cancel_endpoint = determine_api_endpoints(obj, display_options)

    {
      :resource_action_id     => resource_action.id,
      :target_id              => obj.id,
      :target_type            => determine_target_type(obj),
      :real_target_type       => obj.class.base_class.name,
      :dialog_id              => resource_action.dialog_id,
      :force_old_dialog_use   => false,
      :api_submit_endpoint    => submit_endpoint,
      :api_action             => button_name,
      :finish_submit_endpoint => cancel_endpoint,
      :cancel_endpoint        => cancel_endpoint,
      :open_url               => false
    }
  end

  private

  def determine_api_endpoints(obj, display_options = {})
    base_name = obj.class.base_model.name
    case base_name
    when /EmsCluster/
      api_collection_name = "clusters"
      cancel_endpoint = "/ems_cluster"
    when /MiqTemplate/
      api_collection_name = "templates"
      cancel_endpoint = display_options[:cancel_endpoint] || "/vm_or_template/explorer"
    when /GenericObject/
      api_collection_name = "generic_objects"
      cancel_endpoint = if !display_options.empty? && display_options[:display_id]
                          "/service/show/#{display_options[:display_id]}?display=generic_objects"
                        else
                          "/service/explorer"
                        end
    when /ExtManagementSystem/
      api_collection_name = "providers"
      class_name = obj.class.name.demodulize
      cancel_endpoint =
        case class_name
        when "CloudManager"
          "/ems_cloud"
        when "NetworkManager"
          "/ems_network"
        when "CinderManager"
          "/ems_block_storage"
        when "SwiftManager"
          "/ems_object_storage"
        when "ContainerManager"
          "/ems_container/#{obj.id}"
        else
          "/ems_infra"
        end
    when /MiqGroup/
      api_collection_name = "groups"
      cancel_endpoint = "/ops/explorer"
    when /Service/
      api_collection_name = "services"
      cancel_endpoint = "/service/explorer"
    when /Storage/
      api_collection_name = "data_stores"
      cancel_endpoint = "/storage/explorer"
    when /Switch/
      api_collection_name = "switches"
      cancel_endpoint = "/infra_networking/explorer"
    # ^ is necessary otherwise we match CloudTenant
    when /^Tenant/
      api_collection_name = "tenants"
      cancel_endpoint = "/ops/explorer"
    when /User/
      api_collection_name = "users"
      cancel_endpoint = "/ops/explorer"
    when /Vm/
      api_collection_name = "vms"
      cancel_endpoint = display_options[:cancel_endpoint] || "/vm_infra/explorer"
    when /ContainerVolume/
      api_collection_name = base_name.underscore.pluralize
      cancel_endpoint = "/persistent_volume/show/#{obj.id}"
    else
      api_collection_name = base_name.underscore.pluralize
      cancel_endpoint = "/#{base_name.underscore}"
    end

    submit_endpoint = "/api/#{api_collection_name}/#{obj.id}"

    return submit_endpoint, cancel_endpoint
  end

  def determine_target_type(obj)
    case obj.class.name.demodulize
    when /^Ebs/
      "ems_storage"
    when /^Template/
      "miq_template"
    when /InfraManager/
      "ext_management_system"
    when /^Service/
      "service"
    else
      obj.class.base_model.name.underscore.downcase
    end
  end
end
