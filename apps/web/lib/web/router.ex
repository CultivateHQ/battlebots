defmodule Web.Router do
  @moduledoc """
  A Plug router that acts as an interface to control the robot. The
  control page is displayed initially with `get /`. All state changing operations
  are posts.
  """

  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded]
  alias Locomotion.Locomotion
  alias Web.Html

  plug :match
  plug :dispatch

  def start_link do
    cowboy_options = Application.fetch_env!(:web, :cowboy_options)
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], cowboy_options
  end

  get "/" do
    send_resp(conn, 200, "Hello" |> Html.control_page)
  end

  get "/cultivatormobile.css" do
    send_resp(conn, 200, Html.css)
  end

  post "forward" do
    Locomotion.forward
    redirect_home(conn)
  end

  post "back" do
    Locomotion.reverse
    redirect_home(conn)
  end

  post "stop" do
    Locomotion.stop
    redirect_home(conn)
  end

  post "step_rate" do
    step_rate = conn.params["step_rate"] |> String.to_integer
    Locomotion.set_step_rate(step_rate)

    redirect_home(conn)
  end

  post "turn_left" do
    Locomotion.turn_left
    redirect_home(conn)
  end

  post "turn_right" do
    Locomotion.turn_right
    redirect_home(conn)
  end

  match _ do
    send_resp(conn, 404, "<p>Not found.</p><hr/><p>#{conn |> inspect}</p>")
  end

  defp redirect_home(conn) do
    conn
    |> put_resp_header("location", "/")
    |> send_resp(303, "")
  end

end
