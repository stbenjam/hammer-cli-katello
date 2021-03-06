require 'hammer_cli_katello/content_host_package'
require 'hammer_cli_katello/content_host_package_group'
require 'hammer_cli_katello/content_host_errata'

module HammerCLIKatello

  class ContentHostCommand < HammerCLI::AbstractCommand
    module IdDescriptionOverridable
      def self.included(base)
        base.option "--id", "ID",
                    _("ID of the content host")
      end
    end

    class ListCommand < HammerCLIKatello::ListCommand
      include LifecycleEnvironmentNameResolvable
      resource :systems, :index

      output do
        field :uuid, _("ID")
        field :name, _("Name")
      end

      build_options
    end

    class InfoCommand < HammerCLIKatello::InfoCommand
      include LifecycleEnvironmentNameResolvable
      include IdDescriptionOverridable
      resource :systems, :show

      output do
        field :name, _("Name")
        field :uuid, _("ID")
        field :katello_agent_installed, _("Katello Agent Installed"), Fields::Boolean
        field :description, _("Description")
        field :location, _("Location")
        from :environment do
          field :name, _("Lifecycle Environment")
        end
        from :content_view do
          field :name, _("Content View")
        end
        field :entitlementStatus, _("Entitlement Status")
        field :releaseVer, _("Release Version")
        field :autoheal, _("Autoheal")
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      include LifecycleEnvironmentNameResolvable
      resource :systems, :create

      output InfoCommand.output_definition

      success_message _("Content host created")
      failure_message _("Could not create content host")

      def request_params
        super.tap do |params|
          params['type'] = "system"
          params['facts'] = {"uname.machine" => "unknown"}
        end
      end

      validate_options do
        if any(:option_environment_id, :option_environment_name).exist?
          any(:option_content_view_name, :option_content_view_id).required
        end
      end

      build_options :without => [:facts, :type, :installed_products]
    end

    class UpdateCommand < HammerCLIKatello::UpdateCommand
      include IdDescriptionOverridable
      include LifecycleEnvironmentNameResolvable
      resource :systems, :update

      success_message _("Content host updated")
      failure_message _("Could not update content host")

      build_options :without => [:facts, :type, :installed_products]
    end

    class DeleteCommand < HammerCLIKatello::DeleteCommand
      include IdDescriptionOverridable
      include LifecycleEnvironmentNameResolvable
      resource :systems, :destroy

      success_message _("Content host deleted")
      failure_message _("Could not delete content host")

      build_options
    end

    class TasksCommand < HammerCLIKatello::ListCommand
      include IdDescriptionOverridable
      resource :systems, :tasks

      command_name "tasks"

      build_options
    end

    autoload_subcommands

    subcommand "package",
               HammerCLIKatello::ContentHostPackage.desc,
               HammerCLIKatello::ContentHostPackage

    subcommand "package-group",
               HammerCLIKatello::ContentHostPackageGroup.desc,
               HammerCLIKatello::ContentHostPackageGroup

    subcommand "errata",
               HammerCLIKatello::ContentHostErrata.desc,
               HammerCLIKatello::ContentHostErrata
  end

end
