# frozen_string_literal: true

class PushNotificationsController < ApplicationController
  before_action :authenticate_user!

  def subscribe
    data = {
      user_id: current_user.id,
      endpoint: params[:endpoint],
      p256dh: params[:p256dh],
      auth: params[:auth],
      subscribed: true
    }

    if (subscription = PushSubscription.find_by(user_id: current_user.id)).nil?
      subscription = PushSubscription.new(data)
    else
      subscription.update(data)
    end

    if subscription.save
      render json: { message: "Successfully saved subscription" }, status: :ok
    else
      render json: { error: "There was a problem saving the subscription" }, status: :unprocessable_entity
    end
  end

  def subscription_change
    if !(subscription = PushSubscription.find_by(user_id: current_user.id)).nil?
      subscription.update(
        user_id: current_user.id,
        endpoint: params[:endpoint],
        p256dh: params[:p256dh],
        auth: params[:auth]
      )
    else
      render json: { error: "There was a problem updating the subscription" }
    end
  end
end
