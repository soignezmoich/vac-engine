defmodule VacEngine.DocTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import VacEngine.Account
  doctest VacEngine.Account
end
