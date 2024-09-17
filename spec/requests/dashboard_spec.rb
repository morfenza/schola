require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end
  end

end
