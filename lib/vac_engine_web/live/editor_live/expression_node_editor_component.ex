defmodule VacEngineWeb.EditorLive.ExpressionNodeEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias Ecto.Changeset
  alias VacEngine.Processor.Ast
  alias VacEngine.Processor.Library
  alias VacEngineWeb.EditorLive.ExpressionNode
  alias VacEngineWeb.EditorLive.ExpressionNodeEditorComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(
      arguments: [],
      parent_id: nil,
      level: 0,
      argument_index: nil,
      pristine: true
    )
    |> ok()
  end

  @impl true
  def update(
        %{action: {:update_argument, %{index: idx, data: data}}},
        %{
          assigns: %{arguments: arguments}
        } = socket
      ) do
    arguments =
      update_in(arguments, [Access.at(idx)], fn arg ->
        Map.merge(arg, data)
      end)

    socket
    |> assign(arguments: arguments)
    |> update_arguments()
    |> update_variable()
    |> update_ast()
    |> notify_parent()
    |> ok()
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> check_ast()
    |> parse_ast()
    |> check_changeset()
    |> update_types()
    |> update_arguments()
    |> ok()
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{root_module: mod, root_id: id}
        } = socket
      ) do
    send_update(mod,
      id: id,
      action: :save
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"expression_node" => params},
        %{
          assigns: %{
            changeset: changeset
          }
        } = socket
      ) do
    changeset =
      ExpressionNode.changeset(%{changeset | errors: [], valid?: true}, params)

    socket
    |> assign(changeset: changeset)
    |> update_types()
    |> update_arguments()
    |> update_variable()
    |> update_ast()
    |> notify_parent()
    |> pair(:noreply)
  end

  def update_types(
        %{
          assigns: %{
            form_id: form_id,
            changeset: changeset,
            variable_path_index: variable_path_index,
            return_types: types,
            level: level
          }
        } = socket
      ) do
    return_type = Changeset.get_field(changeset, :return_type)

    variables =
      variable_path_index
      |> Enum.filter(fn {_path, var} ->
        var.type == return_type || return_type == :any
      end)
      |> Enum.map(fn {path, _var} ->
        path = Enum.join(path, ".")
        {path, path}
      end)
      |> Enum.sort()

    functions =
      Library.candidates(%{return: return_type})
      |> Enum.map(fn f ->
        {f.short, f.name_arity}
      end)
      |> Enum.sort_by(fn {n, _} ->
        {String.length(n) != 1, n}
      end)

    composed_types =
      types
      |> Enum.map(fn t ->
        subs =
          [:constant, :function, :variable]
          |> Enum.reject(fn n ->
            n == :function && level > 1
          end)
          |> Enum.map(fn st ->
            {st, "#{t}.#{st}"}
          end)

        {t, subs}
      end)

    assign(socket,
      composed_types: composed_types,
      composed_types_hash: form_id <> hash(composed_types),
      variables: variables,
      variables_hash: form_id <> hash(variables),
      functions: functions,
      functions_hash: form_id <> hash(functions)
    )
  end

  def check_ast(%{assigns: %{ast: nil}} = socket), do: socket

  def check_ast(%{assigns: %{ast: ast, return_types: types}} = socket) do
    if Enum.member?(types, Ast.return_type(ast)) do
      socket
    else
      assign(socket, ast: nil)
    end
  end

  def parse_ast(%{assigns: %{pristine: false}} = socket), do: socket

  def parse_ast(%{assigns: %{ast: nil}} = socket) do
    default(socket)
  end

  def parse_ast(%{assigns: %{ast: ast}} = socket) do
    return_type = Ast.return_type(ast)
    node_type = Ast.node_type(ast)
    composed_type = "#{return_type}.#{node_type}"

    el = %ExpressionNode{
      composed_type: composed_type,
      return_type: return_type,
      type: node_type
    }

    node_type
    |> case do
      :constant ->
        %{
          el: %{
            el
            | constant: Ast.describe(ast),
              constant_string: Ast.describe(ast)
          }
        }

      :variable ->
        %{
          el: %{el | variable: Ast.variable_name(ast)}
        }

      :function ->
        fname = Ast.function_name(ast)
        farity = Ast.function_arity(ast)

        arguments =
          Ast.function_arguments(ast)
          |> Enum.with_index()
          |> Enum.map(fn {a, idx} ->
            rtype = Ast.return_type(a)
            %{index: idx, type: rtype, ast: a, return_types: [rtype]}
          end)

        %{
          el: %{el | function: "#{fname}/#{farity}"},
          arguments: arguments
        }
    end
    |> then(fn a ->
      assigns = Map.put(a, :changeset, ExpressionNode.changeset(a.el))

      socket
      |> assign(assigns)
      |> assign(pristine: false)
    end)
  end

  def check_changeset(
        %{assigns: %{changeset: changeset, return_types: return_types}} = socket
      ) do
    return_type = Changeset.get_field(changeset, :return_type)

    if !Enum.member?(return_types, return_type) do
      default(socket)
    else
      socket
    end
  end

  def update_variable(
        %{
          assigns: %{
            changeset: changeset,
            variables: variables
          }
        } = socket
      ) do
    if Changeset.get_field(changeset, :type) == :variable do
      changeset =
        changeset
        |> Changeset.get_field(:variable)
        |> case do
          nil ->
            {_, name} =
              variables
              |> List.first()

            Changeset.put_change(changeset, :variable, name)

          _ ->
            changeset
        end

      assign(socket, changeset: changeset)
    else
      socket
    end
  end

  def update_arguments(
        %{
          assigns: %{
            changeset: changeset,
            functions: functions,
            arguments: arguments
          }
        } = socket
      ) do
    if Changeset.get_field(changeset, :type) == :function do
      changeset =
        changeset
        |> Changeset.get_field(:function)
        |> case do
          nil ->
            {_, name} =
              functions
              |> List.first()

            Changeset.put_change(changeset, :function, name)

          _ ->
            changeset
        end

      fname = Changeset.get_field(changeset, :function)

      return_type = Changeset.get_field(changeset, :return_type)

      candidate =
        Library.candidates(%{
          name: fname,
          return: return_type
        })
        |> List.first()

      {arity, signatures} =
        if candidate do
          {candidate.arity, candidate.signatures}
        else
          {0, []}
        end

      arguments =
        arguments
        |> Enum.with_index()
        |> Enum.map(fn {a, idx} ->
          {idx, a}
        end)
        |> Map.new()

      arguments =
        0..arity
        |> Enum.take(arity)
        |> Enum.reduce({[], []}, fn idx, {acc_types, acc_args} ->
          arg_types =
            signatures
            |> Enum.filter(fn {sig_args, _ret} ->
              List.starts_with?(sig_args, acc_types)
            end)
            |> Enum.map(fn {sig_args, _ret} ->
              Enum.at(sig_args, idx)
            end)
            |> Enum.uniq()

          current_arg =
            Map.get(arguments, idx, %{ast: nil})
            |> Map.merge(%{
              return_types: arg_types,
              index: idx
            })
            |> update_in([:type], fn t ->
              if Enum.member?(arg_types, t) do
                t
              else
                List.first(arg_types)
              end
            end)

          {acc_types ++ [current_arg.type], acc_args ++ [current_arg]}
        end)
        |> elem(1)

      assign(socket, arguments: arguments, changeset: changeset)
    else
      assign(socket, arguments: [])
    end
  end

  def update_ast(
        %{
          assigns: %{
            arguments: arguments,
            changeset: changeset
          }
        } = socket
      ) do
    Changeset.get_field(changeset, :type)
    |> case do
      :constant ->
        if changeset.valid? do
          Changeset.get_field(changeset, :constant)
        else
          nil
        end

      :variable ->
        Changeset.get_field(changeset, :variable)
        |> case do
          v when is_binary(v) ->
            path = String.split(v, ".")
            {:var, [], [path]}

          _ ->
            nil
        end

      :function ->
        fname = Changeset.get_field(changeset, :function)

        try do
          [fname, arity] = String.split(fname, "/")
          fname = String.to_existing_atom(fname)
          arity = String.to_integer(arity)

          args =
            0..arity
            |> Enum.take(arity)
            |> Enum.map(fn n ->
              Enum.at(arguments, n)
              |> case do
                %{ast: ast} ->
                  ast

                _ ->
                  nil
              end
            end)

          {fname, [], args}
        rescue
          _e ->
            nil
        end
    end
    |> then(fn ast ->
      assign(socket, ast: ast)
    end)
  end

  def default(%{assigns: %{return_types: types}} = socket) do
    composed_type = "#{types |> List.first()}.constant"

    el = %ExpressionNode{
      composed_type: composed_type
    }

    socket
    |> assign(
      pristine: false,
      el: el,
      changeset: ExpressionNode.changeset(el)
    )
  end

  def notify_parent(
        %{
          assigns: %{
            ast: ast,
            changeset: changeset,
            parent_id: parent_id,
            argument_index: argument_index,
            root_module: mod,
            root_id: id
          }
        } = socket
      ) do
    if parent_id do
      send_update(ExpressionNodeEditorComponent,
        id: parent_id,
        action:
          {:update_argument,
           %{
             index: argument_index,
             data: %{
               ast: ast,
               type: Changeset.get_field(changeset, :return_type)
             }
           }}
      )
    else
      send_update(mod,
        id: id,
        action: {:update_ast, ast}
      )
    end

    socket
  end
end
