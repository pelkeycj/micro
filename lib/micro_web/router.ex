defmodule MicroWeb.Router do
  use MicroWeb, :router
  import MicroWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MicroWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index

    # associate posts with users
    # TODO associate relations with users??
    resources "/users", UserController do
      resources "/posts", PostController
    end

    post "/relationships", RelationshipController, :follow
    delete "/relationships", RelationshipController, :unfollow

    post "/sessions", SessionController, :login
    delete "/sessions", SessionController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", MicroWeb do
  #   pipe_through :api
  # end
end
