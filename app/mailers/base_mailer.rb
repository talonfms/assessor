class BaseMailer < ApplicationMailer
  default from: "notifications@zivio.net"
  default to: "support@zivio.com"

  def set_common_variables(record = nil)
    account = record.respond_to?(:account) ? record.account : nil
    parent_account = account&.parent_account || (account if account&.is_parent?)
    @logo_url = if parent_account&.logo&.attached?
      proxy_attachment_url(signed_id: parent_account.logo.blob.signed_id)
    else
      host = Rails.application.config.action_mailer.default_url_options[:host]
      URI.join(host, ActionController::Base.helpers.asset_url("zivio_logo.png"))
    end
    @parent_account = parent_account
    @from = t("mailers.shared.from", account: @parent_account&.name || "Zivio")
  end
end
