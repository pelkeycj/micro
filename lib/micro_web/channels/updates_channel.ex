defmodule MicroWeb.UpdatesChannel do
  use MicroWeb, :channel

  def join("updates:all", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("updates:" <> user_id, _payload, socket) do
    if authorized?(user_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_post", payload, socket) do
    case MicroWeb.PostController.create(payload) do
      {:ok, post} ->
        {:reply, {:ok, post}, socket}
      {:error, reasons} ->
        {:reply, {:error, reasons}, socket}
      _ ->
        {:reply, {:error, %{reasons: "Unknown error"}, socket}}
    end
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (updates:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
