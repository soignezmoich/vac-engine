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
end
