defmodule SpikePapertrailWeb.Router do
  use SpikePapertrailWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SpikePapertrailWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpikePapertrailWeb do
    pipe_through :browser

    get "/", ItemController, :index
    get "/items/toggle/:id", ItemController, :toggle
    get "/items/clear", ItemController, :clear_completed
    get "/items/:filter", ItemController, :index
    resources "/items", ItemController
  end
end
