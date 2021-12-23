defmodule VacEngine do
  @moduledoc """
  This context defines the backend part of the VacEngine application
  i.e. it's business logic and data management.

  It contains 3 submodules:

  ### Account
  A role based permission management system.

  ### Processor
  The system allowing to describe, compile and execute processors that
  determine the output to provide for a given input.

  ### Pub
  The system allowing the publication of processors through portals.
  """

  @build_date Timex.format!(Timex.now(), "%d.%m.%Y", :strftime)
  @version System.cmd("git", ["describe", "--always", "--tags"]) |> elem(0)

  def build_date do
    @build_date
  end

  def version do
    @version
  end
end
