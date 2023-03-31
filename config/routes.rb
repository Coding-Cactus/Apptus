# frozen_string_literal: true

Rails.application.routes.draw do
  authenticated :user do
    root 'chats#index', as: :authenticated_root
  end

  devise_for :users, skip: %i[sessions registrations passwords confirmations]

  devise_scope :user do
    root 'devise/sessions#new'

    get    'login',  to: 'devise/sessions#new',     as: :new_user_session
    post   'login',  to: 'devise/sessions#create',  as: :user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session

    put    'account',        to: 'devise/registrations#update'
    delete 'account',        to: 'devise/registrations#destroy'
    post   'account',        to: 'devise/registrations#create'
    get    'register',       to: 'devise/registrations#new',    as: :new_user_registration
    get    'account',        to: 'devise/registrations#edit',   as: :edit_user_registration
    patch  'account',        to: 'devise/registrations#update', as: :user_registration
    get    'account/cancel', to: 'devise/registrations#cancel', as: :cancel_user_registration

    put   'set-password',   to: 'devise/passwords#update'
    post  'set-password',   to: 'devise/passwords#create'
    patch 'set-password',   to: 'devise/passwords#update', as: :user_password
    get   'set-password',   to: 'devise/passwords#edit',   as: :edit_user_password
    get   'reset-password', to: 'devise/passwords#new',    as: :new_user_password

    post 'confirm-email',       to: 'devise/confirmations#create'
    get  'confirm-email',       to: 'devise/confirmations#show', as: :user_confirmation
    get  'resend-confirmation', to: 'devise/confirmations#new',  as: :new_user_confirmation
  end
end
