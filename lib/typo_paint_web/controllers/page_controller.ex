defmodule TypoPaintWeb.PageController do
  use TypoPaintWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
