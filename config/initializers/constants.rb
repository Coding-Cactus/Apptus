# frozen_string_literal: true

COLOURS = %w[#3D9DD2 #6046FC #74CD55 #D69637 #2CAEA6 #DB43C3 #EF3E3E #37BC74].freeze
VAPID_PUBLIC_KEY  = Rails.application.credentials.dig(:push_notifications, :public_key)
VAPID_PRIVATE_KEY = Rails.application.credentials.dig(:push_notifications, :private_key)
