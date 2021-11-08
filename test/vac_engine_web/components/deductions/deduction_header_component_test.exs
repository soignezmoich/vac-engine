defmodule VacEngine.Editor.DeductionHeaderComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Column
  alias VacEngineWeb.Editor.DeductionHeaderComponent

  # Has conds? property

  @cond_columns []
  @assign_columns [
    %Column{type: :assignment, id: 3, variable: ["name"]}
  ]
  @expected_has_conds? false

  test "'build_renderable' should make has_conds? false if no conds" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:has_conds?) == @expected_has_conds?
  end

  @cond_columns [
    %Column{type: :condition, id: 3, variable: ["name"]}
  ]
  @assign_columns []
  @expected_has_conds? true

  test "'build_renderable' should make has_conds? true if some conds" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:has_conds?) == @expected_has_conds?
  end

  # Cond/assign count property

  @cond_columns [
    %Column{type: :condition, id: 1, variable: ["name"]},
    %Column{type: :condition, id: 2, variable: ["surname"]}
  ]
  @assign_columns [
    %Column{type: :assignment, id: 3, variable: ["whole name"]}
  ]
  @expected_cond_count 2
  @expected_assign_count 1

  test "'build_renderable' should make correct cond_count/assign_count" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:cond_count) == @expected_cond_count
    assert renderable |> Map.get(:assign_count) == @expected_assign_count
  end

  # Cond labels property

  @cond_columns [
    %Column{type: :condition, id: 1, variable: ["identity", "name"]},
    %Column{type: :condition, id: 2, variable: ["age"]}
  ]
  @assign_columns []
  @expected_cond_labels ["identity.name", "age"]

  test "'build_renderable' should make correct cond_labels" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:cond_labels) == @expected_cond_labels
  end

  # assign prefix property

  @cond_columns [%Column{type: :condition, id: 2, variable: ["age"]}]

  @assign_columns [
    %Column{type: :assignment, id: 1, variable: ["identity", "name"]},
    %Column{
      type: :assignment,
      id: 2,
      variable: ["identity", "address", "zipcode"]
    },
    %Column{
      type: :assignment,
      id: 2,
      variable: ["identity", "address", "street"]
    }
  ]

  @expected_assign_prefix "identity"

  test "'build_renderable' should make correct assign_prefix" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:assign_prefix) == @expected_assign_prefix
  end

  # assign labels property

  @cond_columns [%Column{type: :condition, id: 2, variable: ["age"]}]

  @assign_columns [
    %Column{type: :assignment, id: 1, variable: ["identity", "name"]},
    %Column{
      type: :assignment,
      id: 2,
      variable: ["identity", "address", "zipcode"]
    },
    %Column{
      type: :assignment,
      id: 2,
      variable: ["identity", "address", "street"]
    }
  ]

  @expected_assign_labels ["name", "address.zipcode", "address.street"]

  test "'build_renderable' should make correct assign_labels" do
    renderable =
      DeductionHeaderComponent.build_renderable(@cond_columns, @assign_columns)

    assert renderable |> Map.get(:assign_labels) == @expected_assign_labels
  end
end
