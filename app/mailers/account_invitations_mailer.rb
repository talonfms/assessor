class AccountInvitationsMailer < BaseMailer
  def invite
    @account_invitation = params[:account_invitation]
    set_common_variables(@account_invitation)
    @account = @account_invitation.account
    @invited_by = @account_invitation.invited_by || User.new(name: "Someone")

    mail(
      to: email_address_with_name(@account_invitation.email, @account_invitation.name),
      from: @from,
      subject: t(".subject", inviter: @invited_by.name, account: @account.name)
    )
  end
end
