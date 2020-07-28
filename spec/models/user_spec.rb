require 'simplecov'
SimpleCov.start
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create' do
    context 'when user is valid' do
      it "all params are present" do
        User.create( email: 'teste@create.com', password: '123456', password_confirmation: '123456' )
        user = User.new( email: 'teste1@create.com', password: '123456', password_confirmation: '123456' ) 
        expect(user).to be_valid
      end
    end

    context 'when params are empty' do
      it "email cant be blank" do
        user = User.new( email: nil ) 
        user.valid?   
        expect(user.errors[:email]).to include("can't be blank")
      end
    
      it "password cant be blank" do
        user = User.new( password: nil ) 
        user.valid?   
        expect(user.errors[:password]).to include("can't be blank")
      end
    
      it "password_confirmation cant be blank" do
        user = User.new( password_confirmation: nil ) 
        user.valid?   
        expect(user.errors[:password_confirmation]).to include("can't be blank")
      end
    end

    context 'when user is not valid' do
    
      it "password and password_conformation need to be equal" do
        user = User.new( password: '123456', password_confirmation: '123456' ) 
        expect(user.password).to eq(user.password_confirmation)
      end
    
      it "email cant been taken" do 
        user = User.create( email: 'contato@ironmaiden.com', password: '123456', password_confirmation: '123456' ) 
        user = User.new( email: 'contato@ironmaiden.com', password: '123456', password_confirmation: '123456' ) 
        user.valid? 
        expect(user.errors[:email]).to include('has already been taken')
      end
    end
  end
end
