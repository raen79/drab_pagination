defmodule DrabPagination.HTML do
  @moduledoc """
  HTML helpers for sorting/searching
  """
  def sort_by_dropdown(entries_assigns_name, sorting_dropdown_options, opts \\ []) do
    "<select class=\"" 
    <> Keyword.get(opts, :class, "")
    <> "\" name=\"sort\" drab-change=\"sort_"
    <> Atom.to_string(entries_assigns_name)
    <> "\">"
      |> add_options_to_dropdown(Map.to_list(sorting_dropdown_options))
      |> Phoenix.HTML.raw()
  end

  defp add_options_to_dropdown(html, []), do: html <> "</select>"

  defp add_options_to_dropdown(html, [{option_text, _} | options]) do
    html = html <> "<option value=\"" <> option_text <> "\">" <> option_text <> "</option>"
    add_options_to_dropdown(html, options)
  end
end