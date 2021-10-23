defmodule VacEngineWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "text-red-500 text-sm",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  def has_error?(form, field) do
    field_error(form, field) |> is_nil() |> Kernel.not()
  end

  def field_error(form, field) do
    form.errors
    |> Keyword.get_values(field)
    |> case do
      [msg | _] -> translate_error(msg)
      _ -> nil
    end
  end

  def inspect_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn changeset, field, msg ->
      s =
        "#{changeset.data.__struct__}"
        |> String.split(".")
        |> List.last()

      name = Ecto.Changeset.get_field(changeset, :name)
      msg = translate_error(msg)

      s =
        [s, name, field]
        |> VacEngine.MapHelpers.compact()
        |> Enum.join(".")

      "#{s}: #{msg}"
    end)
    |> flatten_all
    |> Enum.join("\n")
  end

  defp flatten_all(map) when is_map(map) do
    map
    |> Map.values()
    |> Enum.map(&flatten_all/1)
    |> List.flatten()
  end

  defp flatten_all(list) when is_list(list) do
    list
    |> Enum.map(&flatten_all/1)
    |> List.flatten()
  end

  defp flatten_all(v), do: v

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(VacEngineWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(VacEngineWeb.Gettext, "errors", msg, opts)
    end
  end
end
