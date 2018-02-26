defmodule DrabPagination.Ecto do
  import Ecto.Query, warn: false

  defmacro __using__(repo) do
    quote do      
      def paginate(query, %{per_page: _per_page, page: _page, offset: _offset, new_filter: true} = params) do
        params =
          params
            |> Map.put(:offset, 0)
            |> Map.put(:page, 1)
            |> Map.put(:new_filter, false)
          paginate(query, params)
      end

      def paginate(query, %{per_page: per_page, page: _page, offset: _offset} = params) do
        result = query
                  |> offset(^offset_by(params))
                  |> limit(^per_page)
                  |> filter_and_sort(params)
                  |> unquote(repo).all
        params = Map.put(params, :total_pages, count_pages(query))
        {result, params}
      end
    
      defp count_pages(query) do
        unquote(repo).aggregate(query, :count, :id)
      end

      defp filter_and_sort(query, %{sort: {sort_attr, sort_order}, search: {search_by, search_string}}) do
        search_string = "%" <> search_string <> "%"
        query
          |> order_by({^sort_order, ^sort_attr})
          |> where([table], ilike(field(table, ^search_by), ^search_string))
      end
      
      defp filter_and_sort(query, %{sort: {sort_attr, sort_order}}) do
        order_by(query, {^sort_order, ^sort_attr})
      end

      defp filter_and_sort(query, %{search: {search_by, search_string}}) do
        search_string = "%" <> search_string <> "%"
        where(query, [table], ilike(field(table, ^search_by), ^search_string))
      end

      defp filter_and_sort(query, _), do: query
      
      defp offset_by(%{per_page: per_page, page: page, offset: offset}) do
        (page - 1) * per_page + offset
      end
    end
  end
end