require 'simplecov'
SimpleCov.start
require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do

  let(:host) {"http://localhost:3001/api/v1/"}
  let(:json) {JSON.parse(response.body)}

  describe "GET users#index" do

    it "responds with 200" do
      get("#{host}/users")
      expect(response).to have_http_status(:ok)
    end

    it "returns an array object" do
      get("#{host}/users")
      expect(json).to be_an_instance_of(Array)
    end

    it "returns all users" do
      user1 = User.create(email: "teste1@teste.com", password: "123456", password_confirmation: "123456")
      user2 = User.create(email: "teste2@teste.com", password: "123456", password_confirmation: "123456")
      get("#{host}/users")
      expect(json.length).to be > 1
    end

  end

  describe "GET users#show" do

    it "responds with 200 and only one result and array object" do
      user = User.create(email: 'teste@show.com', password: "123456", password_confirmation: "123456")
      get("#{host}/users/#{user.id}")
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
      expect(json).to be_an_instance_of(Array)
    end

  end

  describe "POST users#login" do

  it 'responds with 201' do
    user = User.create(email: 'teste@login.com', password: "123456", password_confirmation: "123456")
    user_params = {
      email: user.email,
      password: user.password
    }

    post "#{host}/users/login", :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
    expect(response).to have_http_status(:ok)
  end

  it 'responds with 201' do
    user = User.create(email: 'teste@login.com', password: "123456", password_confirmation: "123456")
    user_params = {
      email: user.email,
      password: "wrong password"
    }

    post "#{host}/users/login", :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
    expect(response).to have_http_status(:unauthorized)
  end

  end

  describe "POST users#create" do

    it 'responds with 201' do
      user_params = { user: {
        email: 'johndoe@example.com',
        password: '123456',
        password_confirmation: '123456',
      }}

      post "#{host}/users", :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(response).to have_http_status(:created)
    end

    it 'responds with 404' do
      user_params = { user: {
        email: 'johndoe@example.com',
        password: '123456',
        password_confirmation: nil,
      }}

      post "#{host}/users", :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(response).to have_http_status(:bad_request)
    end

  end

  describe 'PATCH user#change' do
    it 'should change password' do

      user = User.create(email: 'teste@teste.com1', password: "123456", password_confirmation: "123456")
      auth_token = JsonWebToken.encode({user_id: user.id})

      new_activity_params = {
        new_password: '654321',
        password_confirmation: '654321',
        token: auth_token
      }

      patch "#{host}/users/change", :params => new_activity_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(json).to include("status"=> 'Password changed')
      expect(response).to have_http_status(:ok)
    end

    it 'invalid token' do

      new_activity_params = {
        new_password: '654321',
        password_confirmation: '654321',
        token: nil
      }

      patch "#{host}/users/change", :params => new_activity_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(response).to have_http_status(:bad_request)
    end

    it 'expired token' do

      user = User.create(email: 'teste@change.com', password: "123456", password_confirmation: "123456")

      token = {
        exp: 1000000,
        iss: 'issuer_name',
        aud: 'clients',
        user_id: user.id
      }
      
      auth_token = JWT.encode(token, Rails.application.secrets.secret_key_base)

      new_activity_params = {
        new_password: '654321',
        password_confirmation: '654321',
        token: auth_token
      }

      patch "#{host}/users/change", :params => new_activity_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end
    
  end

  describe 'DELETE user#destroy' do
    it 'should delete user' do
      user = User.create(email: 'teste@teste.com2', password: "123456", password_confirmation: "123456")
      auth_token = JsonWebToken.encode({user_id: user.id})

      new_activity_params = {
        token: auth_token
      }

      delete "#{host}/users/#{user.id}", :params => new_activity_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(json).to include("status"=> 'User deleted.')
      expect(response).to have_http_status(:ok)
    end

    it 'should not delete user' do
      user = User.new(id: 0, email: 'teste@teste.com2', password: "123456", password_confirmation: "123456")
      auth_token = JsonWebToken.encode({user_id: user.id})

      new_activity_params = {
        token: auth_token
      }

      delete "#{host}/users/#{user.id}", :params => new_activity_params.to_json, :headers => { "Content-Type": "application/json" }
      expect(response).to have_http_status(:not_found)
    end
  end

end
