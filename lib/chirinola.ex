defmodule Chirinola.Migrate do
  @moduledoc """
  Documentation for `Chirinola`
  """
  require Logger
  alias Chirinola.Repo
  alias Chirinola.Schema.PlantTraits

  @file_path "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
  # @file_path "/Users/ftitor/Downloads/17728_27112021022449/test.txt"
  @wrong_path_message "Wrong path! Enter the absolute path of the file to migrate"
  @file_not_found_message "File not found, enter the absolute path of the file to migrate"
  @headers_row "LastName\tFirstName\tDatasetID\tDataset\tSpeciesName\tAccSpeciesID\tAccSpeciesName\tObservationID\tObsDataID\tTraitID\tTraitName\tDataID\tDataName\tOriglName\tOrigValueStr\tOrigUnitStr\tValueKindName\tOrigUncertaintyStr\tUncertaintyName\tReplicates\tStdValue\tUnitName\tRelUncertaintyPercent\tOrigObsDataID\tErrorRisk\tReference\tComment\t\r"

  def start(path \\ @file_path)
  def start(nil), do: Logger.error(@wrong_path_message)
  def start(""), do: Logger.error(@wrong_path_message)

  def start(path) do
    Logger.info("Inicio de migracion")

    path
    |> File.read()
    |> case do
      {:ok, file_data} ->
        file_data
        |> String.split("\n")
        |> remove_headers()
        |> migrate()

      {:error, reason} ->
        Logger.error("#{@file_not_found_message}. Code: #{inspect(reason)}")
    end
  end

  defp remove_headers([first_row | rest]) when first_row == @headers_row, do: rest
  defp remove_headers(file_data), do: file_data

  defp migrate([]), do: Logger.info("Fin de migracion")

  defp migrate([first_row | rest]) do
    first_row
    |> String.split("\t")
    |> create_struct()
    |> insert_plant()

    migrate(rest)
  end

  defp create_struct([]), do: %{}

  defp create_struct(plant) do
    Map.new()
    |> Map.put("LastName", Enum.at(plant, 0))
    |> Map.put("FirstName", Enum.at(plant, 1))
    |> Map.put("DatasetID", Enum.at(plant, 2))
    |> Map.put("Dataset", Enum.at(plant, 3))
    |> Map.put("SpeciesName", Enum.at(plant, 4))
    |> Map.put("AccSpeciesID", Enum.at(plant, 5))
    |> Map.put("AccSpeciesName", Enum.at(plant, 6))
    |> Map.put("ObservationID", Enum.at(plant, 7))
    |> Map.put("ObsDataID", Enum.at(plant, 8))
    |> Map.put("TraitID", Enum.at(plant, 9))
    |> Map.put("TraitName", Enum.at(plant, 10))
    |> Map.put("DataID", Enum.at(plant, 11))
    |> Map.put("DataName", Enum.at(plant, 12))
    |> Map.put("OriglName", Enum.at(plant, 13))
    |> Map.put("OrigValueStr", Enum.at(plant, 14))
    |> Map.put("OrigUnitStr", Enum.at(plant, 15))
    |> Map.put("ValueKindName", Enum.at(plant, 16))
    |> Map.put("OrigUncertaintyStr", Enum.at(plant, 17))
    |> Map.put("UncertaintyName", Enum.at(plant, 18))
    |> Map.put("Replicates", Enum.at(plant, 19))
    |> Map.put("StdValue", Enum.at(plant, 20))
    |> Map.put("UnitName", Enum.at(plant, 21))
    |> Map.put("RelUncertaintyPercent", Enum.at(plant, 22))
    |> Map.put("OrigObsDataID", Enum.at(plant, 23))
    |> Map.put("ErrorRisk", Enum.at(plant, 24))
    |> Map.put("Reference", Enum.at(plant, 25))
    |> Map.put("Comment", Enum.at(plant, 26))
    |> Map.put("NoNameColumn", Enum.at(plant, 27))
  end

  defp insert_plant(plant) when map_size(plant) == 0, do: Logger.info("Empty row")

  defp insert_plant(plant) do
    %PlantTraits{}
    |> PlantTraits.changeset(plant)
    |> Repo.insert()
  end
end
