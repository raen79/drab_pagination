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
    pagination_handler = :"fetch_next_#{Atom.to_string(entries_assigns_name)}"
    sorting_handler = :"sort_#{Atom.to_string(entries_assigns_name)}"
    sorting_handler_li = :"sort_#{Atom.to_string(entries_assigns_name)}_li"
    searching_handler = :"search_#{Atom.to_string(entries_assigns_name)}"
    
    quote do
      def unquote(pagination_handler)(socket, _sender) do
        if OTP.Agents.Pagination.alive?(socket) do
          OTP.Agents.Pagination.fetch_next_entries(socket,
                                                  unquote(entries_assigns_name),
                                                  unquote(parent_assigns_name),
                                                  unquote(fetch_entries_func))
        else
          Process.sleep(200)
          unquote(pagination_handler)(socket, %{})
        end
      end
      
      # for dropdowns constructed using <dropdown>
      def unquote(sorting_handler)(socket, %{"value" => value}) do
        {sorting_attr, sorting_order} =
          socket
            |> peek(:sorting_dropdown_options)
            |> Map.get(value)
          
        OTP.Agents.Pagination.filter(socket,
                                    unquote(entries_assigns_name),
                                    unquote(parent_assigns_name),
                                    unquote(fetch_entries_func),
                                    sorting_attr,
                                    sorting_order,
                                    :sort)
      end

      # for dropdowns constructed using <li>
      def unquote(sorting_handler_li)(socket, %{"dataset" => %{"orderValue" => value}}) do
        {sorting_attr, sorting_order} =
          socket
            |> peek(:sorting_dropdown_options)
           |> Map.get(value)
        
        OTP.Agents.Pagination.filter(socket,
                                   unquote(entries_assigns_name),
                                   unquote(parent_assigns_name),
                                   unquote(fetch_entries_func),
                                   sorting_attr,
                                   sorting_order,
                                   :sort)
      end
                                   
      def unquote(searching_handler)(socket, %{"dataset" => %{"attr" => search_attr}} = params) when is_binary(search_attr) do
        params = update_in(params["dataset"]["attr"], &(String.to_atom(&1)))
        unquote(searching_handler)(socket, params)
      end
      
      def unquote(searching_handler)(socket, %{"value" => search_value, "dataset" => %{"attr" => search_attr}}) do
        OTP.Agents.Pagination.filter(socket,
                                    unquote(entries_assigns_name),
                                    unquote(parent_assigns_name),
                                    unquote(fetch_entries_func),
                                    search_attr,
                                    search_value,
                                    :search)
      end

      DrabPagination.__using__(unquote(parameters))
    end
  end


  defmacro __using__([
                      [entries_assigns_name: entries_assigns_name, fetch_entries_func: fetch_entries_func]
                      | parameters
                    ])
  do
    pagination_handler = :"fetch_next_#{Atom.to_string(entries_assigns_name)}"
    sorting_handler = :"sort_#{Atom.to_string(entries_assigns_name)}"
    sorting_handler_li = :"sort_#{Atom.to_string(entries_assigns_name)}_li"
    searching_handler = :"search_#{Atom.to_string(entries_assigns_name)}"

    quote do
      def unquote(pagination_handler)(socket, _sender) do
        if OTP.Agents.Pagination.alive?(socket) do
          OTP.Agents.Pagination.fetch_next_entries(socket, unquote(entries_assigns_name), unquote(fetch_entries_func))
        else
          unquote(pagination_handler)(socket, %{})
        end
      end

      # for dropdowns constructed using <dropdown>
      def unquote(sorting_handler)(socket, %{"value" => value}) do
        {sorting_attr, sorting_order} =
          socket
            |> peek(:sorting_dropdown_options)
            |> Map.get(value)

        OTP.Agents.Pagination.filter(socket,
                                   unquote(entries_assigns_name),
                                   unquote(fetch_entries_func),
                                   sorting_attr,
                                   sorting_order,
                                   :sort)
      end

      # for dropdowns constructed using <li>
      def unquote(sorting_handler_li)(socket, %{"dataset" => %{"orderValue" => value}}) do
        {sorting_attr, sorting_order} =
          socket
            |> peek(:sorting_dropdown_options)
            |> Map.get(value)

        OTP.Agents.Pagination.filter(socket,
                                   unquote(entries_assigns_name),
                                   unquote(fetch_entries_func),
                                   sorting_attr,
                                   sorting_order,
                                   :sort)
      end

      def unquote(searching_handler)(socket, %{"dataset" => %{"attr" => search_attr}} = params) when is_binary(search_attr) do
        params = update_in(params["dataset"]["attr"], &(String.to_atom(&1)))
        unquote(searching_handler)(socket, params)
      end

      def unquote(searching_handler)(socket, %{"value" => search_value, "dataset" => %{"attr" => search_attr}}) do
        OTP.Agents.Pagination.filter(socket,
                                    unquote(entries_assigns_name),
                                    unquote(fetch_entries_func),
                                    search_attr, 
                                    search_value,
                                    :search)
      end

      DrabPagination.__using__(unquote(parameters))
    end
  end

  defmacro __using__(_) do
    quote do
      def onconnect(socket) do
        DrabPagination.Agent.start_link(socket)
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
