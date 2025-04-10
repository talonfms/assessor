class Turbo::Ios::PathConfigurationsController < ApplicationController
  # Defines the tabs and rules for the mobile app views
  # To customize this, you can edit the JSON here
  def show
    render json: {
      settings: {
        register_with_account: Jumpstart.config.register_with_account?,
        require_authentication: false,
        tabs: [
          {
            title: "Home",
            path: root_path,
            ios_system_image_name: "house"
          },
          {
            title: "What's New",
            path: announcements_path,
            ios_system_image_name: "megaphone"
          },
          {
            title: "Notifications",
            path: notifications_path,
            ios_system_image_name: "bell",
            show_notification_badge: true
          }
        ]
      },
      rules: [
        {
          patterns: ["/new$", "/edit$"],
          properties: {
            context: "modal"
          }
        },
        {
          patterns: ["^/unauthorized"],
          properties: {
            view_controller: "unauthorized"
          }
        },
        {
          patterns: ["/users/sign_up"],
          properties: {
            view_controller: "registration",
            context: "modal"
          }
        },
        {
          patterns: ["/users/sign_in"],
          properties: {
            view_controller: "authentication",
            context: "modal"
          }
        },
        {
          patterns: ["^/reset_app$"],
          properties: {
            view_controller: "reset_app"
          }
        }
      ]
    }
  end
end
