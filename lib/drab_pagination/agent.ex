defmodule DrabPagination.Agent do
  use Agent

  def start(socket) do
    Agent.start(fn -> 
                  %{page: 1, total_pages: 2, offset: 0}
                end,
                name: agent_name(socket))
  end

  def kill(pid) do
    Agent.stop({:global, pid})
  end

  def fetch_next_entries(socket, entries_assigns_name, parent_assigns_name, fetch_entries_func) do
    parent_assoc = Drab.Live.peek(socket, parent_assigns_name)
    fetch_next_entries(socket, entries_assigns_name, &fetch_entries_func.(parent_assoc, &1))
  end

  def fetch_next_entries(socket, entries_assigns_name, fetch_entries_func) do
    if (next_entries?(socket)) do
      set_per_page(socket, entries_assigns_name)
      adjust_offset(socket, entries_assigns_name)
      increment_page_nr(socket)

      with {new_entries, params} <-
             socket
               |> get_options()
               |> fetch_entries_func.()
      do
        entries = 
          Drab.Live.peek(socket, entries_assigns_name)
          ++ new_entries
        assigns = [{entries_assigns_name, entries}]

        update_page_amount(socket, params.total_pages)
        Drab.Live.poke(socket, assigns)
        set_drab_as_responded(socket)
      end
    else
      unbind_scroll(socket)
      set_drab_as_responded(socket)
    end
  end

  def offset(socket, amount) do
    socket
      |> agent_name
      |> Agent.update(&Map.put(&1, :offset, amount))
  end

  def get_offset(socket) do
    socket
      |> agent_name
      |> Agent.get(&(Map.get(&1, :offset)))
  end
  
  defp adjust_offset(socket, entries_assigns_name) do
    amount_of_entries_on_page = socket
                                  |> Drab.Live.peek(entries_assigns_name)
                                  |> length()
    theoretical_amount_of_entries = get_page_nr(socket) * get_per_page(socket)
    amount = amount_of_entries_on_page - theoretical_amount_of_entries

    offset(socket, amount)
  end

  defp increment_page_nr(socket) do
    new_page_nr = get_page_nr(socket) + 1

    socket
      |> agent_name()
      |> Agent.update(&Map.put(&1, :page, new_page_nr))
  end

  defp update_page_amount(socket, pages_amount) do
    socket
      |> agent_name()
      |> Agent.update(&Map.put(&1, :total_pages, pages_amount))
  end

  defp get_options(socket) do
    socket
      |> agent_name
      |> Agent.get(&(&1))
  end

  defp get_page_nr(socket) do
    socket
      |> agent_name()
      |> Agent.get(&Map.get(&1, :page))
  end

  defp set_per_page(socket, entries_assigns_name) do
    if get_per_page(socket) == nil do
      per_page =
        socket
          |> Drab.Live.peek(entries_assigns_name)
          |> length()
      put_per_page(socket, per_page)
    end
  end

  defp get_per_page(socket) do
    socket
      |> agent_name()
      |> Agent.get(&Map.get(&1, :per_page))
  end

  defp put_per_page(socket, amount) do
    socket
      |> agent_name()
      |> Agent.update(&Map.put(&1, :per_page, amount))
  end

  defp get_page_amount(socket) do
    socket
      |> agent_name()
      |> Agent.get(&Map.get(&1, :total_pages))
  end

  defp next_entries?(socket) do
    get_page_nr(socket) < get_page_amount(socket)
  end

  defp unbind_scroll(socket) do
    Drab.Core.exec_js(socket, "App.object['Paginate'].unbindEvents()")
  end

  defp set_drab_as_responded(socket) do
    Drab.Core.exec_js(socket, "App.object['Paginate'].drabResponded()")
  end

  defp agent_name(socket) do
    {:global, Drab.pid(socket)}
  end
end