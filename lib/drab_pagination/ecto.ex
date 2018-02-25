defmodule DrabPagination.Ecto do
  import Ecto.Query, warn: false
  
  defmacro __using__(repo) do
    quote do
      def paginate(query, %{per_page: per_page, page: _page, offset: _offset} = params) do
        result = query
                  |> offset(^offset_by(params))
                  |> limit(^per_page)
                  |> unquote(repo).all
        params = Map.put(params, :total_pages, count_pages(query))
        {result, params}
      end
    
      defp count_pages(query) do
        unquote(repo).aggregate(query, :count, :id)
      end
      
      defp offset_by(%{per_page: per_page, page: page, offset: offset}) do
        (page - 1) * per_page + offset
      end
    end
  end
end