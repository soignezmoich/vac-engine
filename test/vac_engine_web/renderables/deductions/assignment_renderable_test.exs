defmodule VacEngine.Editor.Renderables.AssignmentRenderableTest do
  use ExUnit.Case

  alias VacEngine.Processor.Assignment
  alias VacEngineWeb.Editor.AssignmentRenderable

  @assignment %Assignment{
    description: "always",
    expression: %VacEngine.Processor.Expression{
      ast: {:age, [signature: {[:date], :integer}],
       [{:var, [signature: {[:name], :date}], [["birthdate"]]}]},
    },
    target: ["age"],
  }

  @path [2, "branches", 1, "assignments", 1]
  @selected_path [2, "branches", 1, "assignments", 1]
  @even_row? true

  @renderable %{
    text: "age @birthdate",
    description: "always",
    even_row?: @even_row?,
    path: @path,
    selected?: true
  }

  test "'build' should build valid renderable from an op assignment" do
    assert AssignmentRenderable.build(@assignment, @path, @selected_path, @even_row?) == @renderable
  end


  @assignment %Assignment{
    description: "always",
    expression: %VacEngine.Processor.Expression{
      ast: {:var, [signature: {[:name], :date}], [["birthdate"]]},
    },
    target: ["age"],
  }

  @path [2, "branches", 1, "assignments", 1]
  @selected_path [2, "branches", 1, "assignments", 1]
  @even_row? true

  @renderable %{
    text: "@birthdate",
    description: "always",
    even_row?: @even_row?,
    path: @path,
    selected?: true
  }

  test "'build' should build valid renderable from a variable assignment" do
    assert AssignmentRenderable.build(@assignment, @path, @selected_path, @even_row?) == @renderable
  end



  @assignment %Assignment{
    description: "always",
    expression: %VacEngine.Processor.Expression{
      ast: false,
    },
    target: ["age"],
  }

  @path [2, "branches", 1, "assignments", 1]
  @selected_path [2, "branches", 1, "assignments", 1]
  @even_row? true

  @renderable %{
    text: "false",
    description: "always",
    even_row?: @even_row?,
    path: @path,
    selected?: true
  }

  test "'build' should build valid renderable from a boolean const assignment" do
    assert AssignmentRenderable.build(@assignment, @path, @selected_path, @even_row?) == @renderable
  end


  @assignment %Assignment{
    description: "always",
    expression: %VacEngine.Processor.Expression{
      ast: "foo",
    },
    target: ["age"],
  }

  @path [2, "branches", 1, "assignments", 1]
  @selected_path [2, "branches", 1, "assignments", 1]
  @even_row? true

  @renderable %{
    text: "foo",
    description: "always",
    even_row?: @even_row?,
    path: @path,
    selected?: true
  }

  test "'build' should build valid renderable from a string const assignment" do
    assert AssignmentRenderable.build(@assignment, @path, @selected_path, @even_row?) == @renderable
  end

end
