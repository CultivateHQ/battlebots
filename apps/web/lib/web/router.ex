defmodule Web.Router do
  @moduledoc """
  A Plug router that acts as an interface to control the robot. The
  control page is displayed initially with `get /`. All state changing operations
  are posts.
  """

  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded]
  alias Locomotion.Locomotion
  alias Laser.LaserControl
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

  post "fire" do
    LaserControl.fire
    redirect_home(conn)
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
    case Integer.parse(conn.params["step_rate"]) do
      {step_rate, _} -> Locomotion.set_step_rate(step_rate)
      _ -> nil
    end
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

  post "reset" do
    Events.broadcast(:laser_hits, :reset)
    redirect_home(conn)
  end

  match _ do
    redirect_home(conn)
  end

  defp redirect_home(conn) do
    conn
    |> put_resp_header("location", "/")
    |> send_resp(303, "")
  end

end
