defmodule VacEngineWeb.Editor.Deductions do
  use Phoenix.Component

  import VacEngineWeb.PathHelpers

  def deductions(assigns) do
    deductions_with_path =
      assigns.deductions
      |> Enum.with_index()
      |> Enum.map(fn {deduction, index} ->
        {[index | assigns.path], deduction}
      end)

    assigns =
      assign(assigns,
        deductions_with_path: deductions_with_path
      )

    ~H"""
      <div class="overflow-x-scroll">

        <%= for {path, deduction} <- @deductions_with_path do %>
          <.deduction deduction={deduction} path={path} selection_path={@selection_path}/>
        <% end %>
      </div>
      <br/>

    """

    # <%= if @selected do %>
    #   <.cell_edit_panel
    #     dot_path={@selection_path}
    #   />
    # <% end %>
  end

  def deduction(assigns) do
    %{deduction: %{branches: branches, columns: columns}, path: path} = assigns

    cond_columns =
      columns
      |> Enum.filter(&(&1.type == :condition))
      |> Enum.map(&%{id: &1.id, variable_path: &1.variable})

    target_columns =
      columns
      |> Enum.filter(&(&1.type == :assignment))
      |> Enum.map(&%{id: &1.id, variable_path: &1.variable})

    cond_paths =
      cond_columns
      |> Enum.map(& &1.variable_path)

    target_paths =
      target_columns
      |> Enum.map(& &1.variable_path)

    {target_paths_prefix, truncated_target_paths} = extract_prefix(target_paths)

    branches_with_path =
      branches
      |> Enum.with_index()
      |> Enum.map(fn {branch, index} ->
        {index, [index | ["branches" | path]], branch}
      end)

    var_indent =
      if length(target_paths_prefix) > 0 && length(target_paths) > 1 do
        "--> "
      else
        ""
      end

    # IO.inspect(cond_columns)

    assigns =
      assign(assigns,
        cond_columns: cond_columns,
        target_columns: target_columns,
        cond_paths: cond_paths,
        target_paths: target_paths,
        target_paths_prefix: target_paths_prefix,
        truncated_target_paths: truncated_target_paths,
        var_indent: var_indent,
        branches_with_path: branches_with_path
      )

    ~H"""
    <div>
      <br/>
      <br/>
      <div>
        <table class="min-w-full">
          <thead>
            <tr>
              <%= if Enum.count(@cond_columns) > 0 do %>
              <th colspan={Enum.count(@cond_columns)} class="bg-cream-500 text-white px-4">
              </th>
              <th><div class="w-2"/></th>
              <% end %>
              <th colspan={Enum.count(@target_columns)} class="whitespace-nowrap bg-blue-500 text-white py-1 px-4">
                <%= @target_paths_prefix |> Enum.join(".") %> ->
              </th>
            </tr>
            <tr>
              <%= if Enum.count(@cond_columns) > 0 do %>
                <%= for cond_path <- @cond_paths do %>
                  <th class="bg-cream-400 text-white py-1 px-4">
                    <div class="mx-1">
                      <%= cond_path |> Enum.join(".") %>
                    </div>
                  </th>
                <% end %>
                <th class="bg-white">
                </th>
              <% end %>
              <%= for target_path <- @truncated_target_paths do %>
                <% target_path = if Enum.count(target_path) > 0 do target_path else [List.last(@target_paths_prefix)] end %>
                <th class="bg-blue-400 text-white py-1 px-4">
                  <div class="mx-1">
                    <%= target_path |> Enum.join(".") %>
                  </div>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody>
            <%= for {index, path, branch} <- @branches_with_path do %>
              <tr>
                <.branch
                  branch={branch}
                  index={index}
                  path={path}
                  cond_columns={cond_columns}
                  target_columns={target_columns}
                  selection_path={@selection_path} />
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

    </div>
    """
    # <tr>
    #   <td colspan={Enum.count(@cond_columns) +Enum.count(@target_columns) + 1}>
    #     <div class="h-1"/>
    #     <button class="btn-light m-1">
    #       <svg class="h-5 w-5 inline-block m-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    #         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" style="fill: none;" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
    #       </svg>
    #     </button>
    #     <button class="btn-light m-1">
    #       <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block m-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    #         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18" />
    #       </svg>
    #     </button>
    #     <button class="btn-light m-1">
    #       <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block m-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    #         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
    #       </svg>
    #     </button>
    #     <button class="btn-light m-1">
    #       <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block m-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    #         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
    #       </svg>
    #     </button>
    #     <hr/>
    #   </td>
    # </tr>
  end

  def branch(assigns) do
    %{
      branch: %{conditions: conditions, assignments: assignments},
      cond_columns: cond_columns,
      target_columns: target_columns,
      path: path
    } = assigns

    cond_cells =
      cond_columns
      |> Enum.map(fn
        %{id: column_id} ->
          {column_id, Enum.find(conditions, &(&1.column_id == column_id))}
      end)
      |> Enum.map(fn
        {column_id, %{expression: expression}} ->
          %{
            expression: expression.ast,
            path: [column_id | ["conditions" | path]]
          }

        {column_id, nil} ->
          %{expression: nil, path: [column_id | ["conditions" | path]]}
      end)

    target_cells =
      target_columns
      |> Enum.map(fn
        %{id: column_id} ->
          {column_id, Enum.find(assignments, &(&1.column_id == column_id))}
      end)
      |> Enum.map(fn
        {column_id, nil} ->
          %{
            expression: nil,
            description: "",
            path: [column_id | ["assignments" | path]]
          }

        {column_id, a} ->
          %{
            expression: a.expression.ast,
            description: a.description,
            path: [column_id | ["assignments" | path]]
          }
      end)

    # target_columns
    # |> Enum.map(fn
    #   %{id: column_id} -> Enum.find(assignments, &(&1.column_id == column_id))
    #  end)
    # |> Enum.map(fn
    #     nil -> "nil"
    #     a -> a.description
    #   end)
    # |> IO.inspect()

    assigns =
      assign(assigns,
        cond_cells: cond_cells,
        target_cells: target_cells
      )

    ~H"""
    <%= if Enum.count(cond_cells) > 0 do %>
      <%= for cond_cell <- @cond_cells do %>
        <.cell
          expression={cond_cell.expression}
          path={cond_cell.path}
          selection_path={@selection_path}
          description={nil}
          is_condition={true}
          even={rem(@index, 2) == 0} />
      <% end %>
      <td class="bg-white text-gray-300 w-5">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </td>
    <% end %>
    <%= for target_cell <- @target_cells do %>
      <.cell
        expression={target_cell.expression}
        description={target_cell.description}
        path={target_cell.path}
        selection_path={@selection_path}
        is_condition={false}
        even={rem(@index, 2) == 0} />
    <% end %>
    """
  end

  def cell(assigns) do
    {type, value, args} =
      case assigns.expression do
        {:var, _signature, [elems]} when is_list(elems) ->
          {"variable", "@#{elems |> Enum.join(".")}", []}

        {op, _signature, args} ->
          {"operator", op, args}

        const when is_boolean(const) ->
          {"const", inspect(const), []}

        const when is_binary(const) ->
          {"const", inspect(const), []}

        const when is_number(const) ->
          {"const", inspect(const), []}

        nil ->
          {"nil", "-", []}

        _ ->
          {}
      end

    dot_path =
      assigns.path
      |> Enum.reverse()
      |> Enum.join(".")

    selected = assigns.selection_path == dot_path

    args =
      args
      |> Enum.map(fn
        {:var, _signature, [elems]} when is_list(elems) ->
          "@#{elems |> Enum.join(".")}"

        const ->
          inspect(const)
      end)

    args =
      case assigns.is_condition do
        true -> args |> Enum.drop(1)
        false -> args
      end

    bg_color =
      case {assigns.is_condition, value, selected} do
        {_, _, true} -> "bg-pink-600 text-white"
        {true, :is_true, _} -> "bg-green-200 font-semibold"
        {true, :is_false, _} -> "bg-red-200"
        {true, "-", _} -> "bg-cream-200"
        {true, _, _} -> "bg-yellow-200"
        {_, "true", _} -> "bg-green-200 font-semibold"
        {false, _, _} -> "bg-blue-200"
      end

    bg_opacity =
      case {selected, assigns.even} do
        {true, _} -> ""
        {false, true} -> "bg-opacity-30"
        {false, false} -> "bg-opacity-50"
      end

    cell_style =
      "#{bg_color} #{bg_opacity} px-2 py-1 clickable whitespace-nowrap"

    assigns =
      assign(assigns,
        type: type,
        value: value,
        args: args,
        cell_style: cell_style,
        dot_path: dot_path,
        selected: selected
      )

    ~H"""
      <td class={@cell_style} phx-value-path={@dot_path} phx-click={"select_cell"}>
        <%= @value %>
        &nbsp;
        <%= @args |> Enum.join(", ") %>
        <%= if is_binary(@description) && @description != "" do %>
          (<%= @description %>)
        <% end %>
      </td>
    """
  end

  def cell_edit_panel(assigns) do
    # extract cell from path

    ~H"""
      <div class="cell-edit-panel">
        <div>
          <%= @dot_path %>
        </div>
        value:
        <select class="form-fld">
          <option><%= @value %></option>
        </select>
      </div>
    """
  end
end
