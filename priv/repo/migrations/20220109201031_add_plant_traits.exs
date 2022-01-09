defmodule Chirinola.Repo.Migrations.AddPlantTraits do
  use Ecto.Migration

  def up do
    create table(:plant_traits, primary_key: true)
      add :first_name, :string
      add :LastName, :string
      add :FirstName, :string
      add :DatasetID, :string
      add :Dataset, :string
      add :SpeciesName, :string
      add :AccSpeciesID, :string
      add :AccSpeciesName, :string
      add :ObservationID, :string
      add :ObsDataID, :string
      add :TraitID, :string
      add :TraitName, :string
      add :DataID, :string
      add :DataName, :string
      add :OriglName, :string
      add :OrigValueStr, :string
      add :OrigUnitStr, :string
      add :ValueKindName, :string
      add :OrigUncertaintyStr, :string
      add :UncertaintyName, :string
      add :Replicates, :string
      add :StdValue, :string
      add :UnitName, :string
      add :RelUncertaintyPercent, :string
      add :OrigObsDataID, :string
      add :ErrorRisk, :string
      add :Reference, :string
      add :Comment, :string
      timestamps()
    end
  end

  def down do
    drop(table(:plant_traits))
  end
end
