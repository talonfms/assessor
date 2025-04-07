class ProxyController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    expires_in 1.week
    send_data blob.download,
      type: blob.content_type,
      disposition: "inline"
  end
end
