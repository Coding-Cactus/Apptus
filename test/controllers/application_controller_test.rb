# frozen_string_literal: true

require "test_helper"

class ChatMemberControllerTest < ActionDispatch::IntegrationTest
  test "should get ping" do
    get ping_url

    assert_response :success
    assert_match "Pong 🌵", @response.body
  end
end
