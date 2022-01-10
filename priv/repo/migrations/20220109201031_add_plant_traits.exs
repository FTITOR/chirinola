defmodule Chirinola.Repo.Migrations.AddPlantTraits do
  use Ecto.Migration

  def up do
    create table(:plant_traits, primary_key: true)
      add :LastName, :string
      add :FirstName, :string
      add :DatasetID, :integer
      add :Dataset, :string
      add :SpeciesName, :string
      add :AccSpeciesID, :integer
      add :AccSpeciesName, :string
      add :ObservationID, :integer
      add :ObsDataID, :integer
      add :TraitID, :integer
      add :TraitName, :string
      add :DataID, :integer
      add :DataName, :string
      add :OriglName, :string
      add :OrigValueStr, :string
      add :OrigUnitStr, :string
      add :ValueKindName, :string
      add :OrigUncertaintyStr, :string
      add :UncertaintyName, :string
      add :Replicates, :integer
      add :StdValue, :float
      add :UnitName, :string
      add :RelUncertaintyPercent, :float
      add :OrigObsDataID, :number
      add :ErrorRisk, :float
      add :Reference, :string
      add :Comment, :string
      add :no_name_column, :string
      timestamps()
    end
  end

  def down do
    drop(table(:plant_traits))
  end
end
