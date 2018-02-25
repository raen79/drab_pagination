defmodule DrabPagination do
  @moduledoc """
  Interface for DrabPagination Application
  """
  defmacro __using__([
                      [
                        entries_assigns_name: entries_assigns_name,
                        parent_assigns_name: parent_assigns_name,
                        fetch_entries_func: fetch_entries_func
                      ]
                      | parameters
                    ])
  do
    handler = :"fetch_next_#{Atom.to_string(entries_assigns_name)}"
    
    quote do
      def unquote(handler)(socket, _sender) do
        DrabPagination.Agent.fetch_next_entries(socket,
                                                 unquote(entries_assigns_name),
                                                 unquote(parent_assigns_name),
                                                 unquote(fetch_entries_func))
      end

      DrabPagination.__using__(unquote(parameters))
    end
  end


  defmacro __using__([
                      [entries_assigns_name: entries_assigns_name, fetch_entries_func: fetch_entries_func]
                      | parameters
                    ])
  do
    handler = :"fetch_next_#{Atom.to_string(entries_assigns_name)}"

    quote do
      def unquote(handler)(socket, _sender) do
        DrabPagination.Agent.fetch_next_entries(socket, unquote(entries_assigns_name), unquote(fetch_entries_func))
      end

      DrabPagination.__using__(unquote(parameters))
    end
  end

  defmacro __using__(_) do
    quote do
      def onconnect(socket) do
        DrabPagination.Agent.start(socket)
        Drab.Core.put_store(socket, :pid, Drab.pid(socket))
      end
    
      def ondisconnect(store, _session) do
        store
          |> Map.get(:pid)
          |> DrabPagination.Agent.kill()
      end
    end
  end
end
