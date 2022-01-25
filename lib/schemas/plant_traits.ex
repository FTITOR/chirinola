defmodule Chirinola.Schema.PlantTraits do
  @moduledoc """
  Documentation for `Migrator`
  """

  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(LastName FirstName DatasetID Dataset SpeciesName AccSpeciesID AccSpeciesName ObservationID ObsDataID TraitID TraitName DataID DataName OriglName OrigValueStr OrigUnitStr ValueKindName OrigUncertaintyStr UncertaintyName Replicates StdValue UnitName RelUncertaintyPercent OrigObsDataID ErrorRisk Reference Comment NoNameColumn)a

  schema "plant_traits" do
    field(:LastName, :string)
    field(:FirstName, :string)
    field(:DatasetID, :integer)
    field(:Dataset, :string)
    field(:SpeciesName, :string)
    field(:AccSpeciesID, :integer)
    field(:AccSpeciesName, :string)
    field(:ObservationID, :integer)
    field(:ObsDataID, :integer)
    field(:TraitID, :integer)
    field(:TraitName, :string)
    field(:DataID, :integer)
    field(:DataName, :string)
    field(:OriglName, :string)
    field(:OrigValueStr, :string)
    field(:OrigUnitStr, :string)
    field(:ValueKindName, :string)
    field(:OrigUncertaintyStr, :string)
    field(:UncertaintyName, :string)
    field(:Replicates, :float)
    field(:StdValue, :float)
    field(:UnitName, :string)
    field(:RelUncertaintyPercent, :float)
    field(:OrigObsDataID, :integer)
    field(:ErrorRisk, :float)
    field(:Reference, :string)
    field(:Comment, :string)
    field(:NoNameColumn, :string)
    timestamps()
  end

  def changeset(plant_trait, params) do
    plant_trait
    |> cast(params, @fields)
  end
end
