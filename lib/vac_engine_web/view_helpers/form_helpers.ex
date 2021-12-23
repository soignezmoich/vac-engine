defmodule VacEngineWeb.FormHelpers do
  use Phoenix.HTML
  import VacEngineWeb.ErrorHelpers

  def label_line_tag(form, field, label) do
    content_tag(
      :div,
      [
        label(form, field, label, class: "flex-grow uppercase text-cream-600"),
        error_tag(form, field)
      ],
      class: "flex items-baseline"
    )
  end

  def form_value(form, field) do
    input_value(form, field)
    |> html_escape
    |> safe_to_string
  end

  def hash(val) do
    :crypto.hash(:md5, inspect(val)) |> Base.encode16()
  end
end
