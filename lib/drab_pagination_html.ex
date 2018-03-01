defmodule DrabPagination.HTML do
  @moduledoc """
  HTML helpers for sorting/searching
  """
  def sort_by_dropdown(entries_assigns_name, sorting_dropdown_options, opts \\ []) do
    # computes HTML for sorting dropdown using the given parameters
    # optional parameters will be empty string if not given
    "<select class=\"" 
    <> Keyword.get(opts, :class, "")
    <> "\" name=\"sort\" drab-change=\"sort_"
    <> Atom.to_string(entries_assigns_name)
    <> "\">"
      |> add_options_to_dropdown(Map.to_list(sorting_dropdown_options))
      |> Phoenix.HTML.raw()
  end

  def search(entries_assigns_name, attribute, opts \\ []) do
    # computes HTML for search input using the given parameters
    # optional parameters will be empty string if not given
    Phoenix.HTML.raw("<input name=\"search\" data-attr=\""
                     <> Atom.to_string(attribute)
                     <> "\" drab-keyup=\"search_"
                     <> Atom.to_string(entries_assigns_name)
                     <> "\" placeholder= \""
                     <> Keyword.get(opts, :placeholder, "")
                     <> "\" type=\"text\" id=\""
                     <> Keyword.get(opts, :id, "")
                     <> "\" class=\""
                     <> Keyword.get(opts, :class, "")
                     <> "\"> </input>")
  end

  defp add_options_to_dropdown(html, []), do: html <> "</select>"

  defp add_options_to_dropdown(html, [{option_text, _} | options]) do
    html = html <> "<option value=\"" <> option_text <> "\">" <> option_text <> "</option>"
    add_options_to_dropdown(html, options)
  end
end