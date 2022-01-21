defmodule Chirinola.Migrator do
  @moduledoc """
  Documentation for `Chirinola`
  """
  require Logger
  alias Chirinola.Repo
  alias Chirinola.Schema.PlantTraits

  @type encoding_mode ::
          {
            :encoding,
            :latin1
            | :unicode
            | :utf8
            | :utf16
            | :utf32
            | {:utf16, :big | :little}
            | {:utf32, :big | :little}
          }

  @default_encoding {:encoding, :latin1}
  @valid_encondigs [
    {:encoding, :latin1},
    {:encoding, :unicode},
    {:encoding, :utf8},
    {:encoding, :utf16},
    {:encoding, :utf32},
    {:encoding, {:utf16, :big}},
    {:encoding, {:utf16, :little}},
    {:encoding, {:utf32, :big}},
    {:encoding, {:utf32, :little}}
  ]

  @wrong_path_message "Wrong path! Enter the absolute path of the file to migrate"
  @invalid_encoding_mode "The decoding format is invalid, check the valid formats"
  @file_not_found_message "File not found, enter the absolute path of the file to migrate"
  @headers_row "LastName\tFirstName\tDatasetID\tDataset\tSpeciesName\tAccSpeciesID\tAccSpeciesName\tObservationID\tObsDataID\tTraitID\tTraitName\tDataID\tDataName\tOriglName\tOrigValueStr\tOrigUnitStr\tValueKindName\tOrigUncertaintyStr\tUncertaintyName\tReplicates\tStdValue\tUnitName\tRelUncertaintyPercent\tOrigObsDataID\tErrorRisk\tReference\tComment\t\n"

  def count() do
    "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
    |> File.read!()
    |> String.split("\n")
    |> length()
  end

  @spec start(String.t(), encoding_mode()) :: :ok
  def start(path, encoding_mode \\ @default_encoding)
  def start(nil, _encoding_mode), do: Logger.error(@wrong_path_message)
  def start("", _encoding_mode), do: Logger.error(@wrong_path_message)

  def start(_path, encoding_mode) when encoding_mode not in @valid_encondigs,
    do: Logger.error(@invalid_encoding_mode)

  def start(_path, encoding_mode) do
    Logger.info("** MIGRATION PROCESS STARTED!")
    path = "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
    # path = "/Users/ftitor/Downloads/17728_27112021022449/test.txt"

    path
    |> File.exists?()
    |> case do
      true ->
        Logger.info("** PROCESSING FILE (#{path})...")

        path
        |> File.stream!([encoding_mode], :line)
        |> Stream.map(&migrate_row/1)
        |> Stream.run()

        Logger.info("** MIGRATION FINISHED!")

      false ->
        Logger.error(@file_not_found_message)
    end
  end

  defp migrate_row(row) when row == @headers_row,
    do: Logger.info("- IGNORING DOCUMENT HEADERS")

  defp migrate_row(row) do
    row
    |> String.split("\n")
    |> Enum.at(0)
    |> String.split("\t")
    |> create_struct()
    |> insert_plant()
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

  defp insert_plant(plant) when map_size(plant) == 0, do: Logger.info("- Empty row")

  defp insert_plant(plant) do
    %PlantTraits{}
    |> PlantTraits.changeset(plant)
    |> Repo.insert()
    |> case do
      {:ok, plant_trait} ->
        {:ok, plant_trait}

      {:error, %Ecto.Changeset{changes: changes, errors: error}} ->
        Logger.error("## PARAMS")
        Logger.info(plant)
        Logger.error("## INFORMATION TO INSERT:")
        Logger.info(changes)
        Logger.error("## ERROR DETAIL:")
        Logger.info(error)
        File.write("errors.text", changes)
    end
  end
end
