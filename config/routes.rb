# frozen_string_literal: true

Rails.application.routes.draw do
  # resource :dashboard, only: :show
  get '/dashboard', to: 'dashboard#show'

  resources :students
  resources :enrollments, param: :code
  resources :grades
  resources :teachers
  resources :teacher_assignments
  resources :courses
  resources :exams
  resources :subjects

  root 'dashboard#show'
end
