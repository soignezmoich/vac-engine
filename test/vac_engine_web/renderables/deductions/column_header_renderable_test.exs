defmodule VacEngine.Editor.Renderables.ColumnHeaderRenderableTest do
  use ExUnit.Case

  alias VacEngine.Processor.Column
  alias VacEngineWeb.Editor.ColumnHeaderRenderable


  @column %Column{
    description: nil,
    position: 0,
    type: :assignment,
    variable: ["main", "my", "age"],
  }

  @min_distinct_path ["age"]
  @var_may_be_nil? false
  @defaults_to_false? false

  @renderable %{
    text: "age",
    type: :assignment,
    var_may_be_nil?: false,
    defaults_to_false?: false
  }

  test "'build' should build valid renderable from a column with atomic path" do
    assert ColumnHeaderRenderable.build(
      @column, @min_distinct_path, @var_may_be_nil?, @defaults_to_false?
    ) == @renderable
  end


  @column %Column{
    description: nil,
    position: 0,
    type: :assignment,
    variable: ["main", "my", "age"],
  }

  @min_distinct_path ["my", "age"]
  @var_may_be_nil? false
  @defaults_to_false? false

  @renderable %{
    text: "my.age",
    type: :assignment,
    var_may_be_nil?: false,
    defaults_to_false?: false
  }

  test "'build' should build valid renderable from a column with composite path" do
    assert ColumnHeaderRenderable.build(
      @column, @min_distinct_path, @var_may_be_nil?, @defaults_to_false?
    ) == @renderable
  end


  @column %Column{
    description: "age description",
    position: 0,
    type: :assignment,
    variable: ["main", "my", "age"],
  }

  @min_distinct_path ["age"]
  @var_may_be_nil? false
  @defaults_to_false? false

  @renderable %{
    text: "age description",
    type: :assignment,
    var_may_be_nil?: false,
    defaults_to_false?: false
  }

  test "'build' should build valid renderable from a column with description" do
    assert ColumnHeaderRenderable.build(
      @column, @min_distinct_path, @var_may_be_nil?, @defaults_to_false?
    ) == @renderable
  end


end
