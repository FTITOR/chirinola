defmodule Chirinola.PlantTrait do
  @moduledoc """
  Documentation for `PlantTrait` module.
  """

  require Logger
  alias Chirinola.Repo
  alias Chirinola.Schema.PlantTraits, as: PlantTraitsSchema

  @headers_line "LastName\tFirstName\tDatasetID\tDataset\tSpeciesName\tAccSpeciesID\tAccSpeciesName\tObservationID\tObsDataID\tTraitID\tTraitName\tDataID\tDataName\tOriglName\tOrigValueStr\tOrigUnitStr\tValueKindName\tOrigUncertaintyStr\tUncertaintyName\tReplicates\tStdValue\tUnitName\tRelUncertaintyPercent\tOrigObsDataID\tErrorRisk\tReference\tComment\t\n"

  @doc """
  This function `migrate_line/2` processes a line of the file to insert it into the database
  """
  @spec migrate_line(binary(), binary()) :: {:ok, struct()} | {:error, Ecto.ChangeError}
  def migrate_line(line, _) when line == @headers_line,
    do: Logger.info("Skip file headers!")

  def migrate_line("\n", _), do: Logger.info("EMPTY LINE")

  def migrate_line(line, file_name) do
    line
    |> String.split("\n")
    |> Enum.at(0)
    |> String.split("\t")
    |> create_struct(file_name)
    |> insert_plant()
  end

  defp create_struct([], _), do: %{}

  defp create_struct(plant, file_name) do
    Map.new()
    |> Map.put("last_name", Enum.at(plant, 0))
    |> Map.put("first_name", Enum.at(plant, 1))
    |> Map.put("dataset_id", Enum.at(plant, 2))
    |> Map.put("dataset", Enum.at(plant, 3))
    |> Map.put("species_name", Enum.at(plant, 4))
    |> Map.put("acc_species_id", Enum.at(plant, 5))
    |> Map.put("acc_species_name", Enum.at(plant, 6))
    |> Map.put("observation_id", Enum.at(plant, 7))
    |> Map.put("obs_data_id", Enum.at(plant, 8))
    |> Map.put("trait_id", Enum.at(plant, 9))
    |> Map.put("trait_name", Enum.at(plant, 10))
    |> Map.put("data_id", Enum.at(plant, 11))
    |> Map.put("data_name", Enum.at(plant, 12))
    |> Map.put("origl_name", Enum.at(plant, 13))
    |> Map.put("orig_value_str", Enum.at(plant, 14))
    |> Map.put("orig_unit_str", Enum.at(plant, 15))
    |> Map.put("value_kind_name", Enum.at(plant, 16))
    |> Map.put("orig_uncertainty_str", Enum.at(plant, 17))
    |> Map.put("uncertainty_name", Enum.at(plant, 18))
    |> Map.put("replicates", validate_replicate(Enum.at(plant, 19)))
    |> Map.put("std_value", Enum.at(plant, 20))
    |> Map.put("unit_name", Enum.at(plant, 21))
    |> Map.put("rel_uncertainty_percent", Enum.at(plant, 22))
    |> Map.put("orig_obs_data_id", Enum.at(plant, 23))
    |> Map.put("error_risk", Enum.at(plant, 24))
    |> Map.put("reference", Enum.at(plant, 25))
    |> Map.put("comment", Enum.at(plant, 26))
    |> Map.put("no_name_column", Enum.at(plant, 27))
    |> Map.put("file", file_name)
  end

  defp insert_plant(plant) when map_size(plant) == 0, do: Logger.info("- EMPTY LINE")
  defp insert_plant(plant), do: insert(plant)

  defp validate_replicate(nil), do: nil
  defp validate_replicate(""), do: nil
  defp validate_replicate(replicate) when is_float(replicate), do: replicate

  defp validate_replicate(replicate) when is_binary(replicate) do
    replicate
    |> Float.parse()
    |> case do
      {float, _} ->
        float

      :error ->
        Logger.error("Replicate invalid: #{replicate}")
        nil
    end
  end

  defp validate_replicate(_), do: nil

  @doc """
  Insert a Plant trait record into the database
  """
  @spec insert(map()) :: {:ok, struct()} | {:error, Ecto.ChangeError}
  def insert(plant_traits_attrs) do
    %PlantTraitsSchema{}
    |> PlantTraitsSchema.changeset(plant_traits_attrs)
    |> Repo.insert()
    |> case do
      {:ok, plant_trait} ->
        {:ok, plant_trait}

      {:error, %Ecto.Changeset{changes: changes, errors: error}} ->
        Logger.error("ERROR WHILE INSERTING THE FOLLOWING RECORD:")
        Logger.info("#PARAMS: #{inspect(plant_traits_attrs)}")
        Logger.info("#CHANGES: #{inspect(changes)}")
        Logger.info("#ERROR DETAIL: #{inspect(error)}")
        File.write("errors-#{NaiveDateTime.utc_now()}.txt", changes)
        error
    end
  end
end
