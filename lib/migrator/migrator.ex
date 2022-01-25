defmodule Chirinola.Migrator do
  @moduledoc """
  Documentation for `Migrator`
  """
  require Logger
  alias Chirinola.Repo
  alias Chirinola.Schema.PlantTraits

  @typedoc """
  Encoding modes, a tuple of two atoms.

  `{:encoding, :latin1}`, `{:encoding, :unicode}`, `{:encoding, :utf8}`,
  `{:encoding, :utf16}`, `{:encoding, :utf32}`, `{:encoding, {:utf16, :big}}`,
  `{:encoding, {:utf16, :little}}`, `{:encoding, {:utf32, :big}}`,
  `{:encoding, {:utf32, :little}}`
  """
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
  @headers_line "LastName\tFirstName\tDatasetID\tDataset\tSpeciesName\tAccSpeciesID\tAccSpeciesName\tObservationID\tObsDataID\tTraitID\tTraitName\tDataID\tDataName\tOriglName\tOrigValueStr\tOrigUnitStr\tValueKindName\tOrigUncertaintyStr\tUncertaintyName\tReplicates\tStdValue\tUnitName\tRelUncertaintyPercent\tOrigObsDataID\tErrorRisk\tReference\tComment\t\n"

  @doc """
  Provide the absolute path of the file as a string,
  the function `count/1` will return the number of lines that the file contains.


  ## Examples

      iex> Chirinola.Migrator.count("some_file.txt")
      1000

  If the path provided is incorrect an error will be displayed

  ## Examples

      iex> Chirinola.Migrator.count("bad_file.txt")
      File not found, enter the absolute path of the file to migrate, code: enoent
      :error

  """

  @spec count(String.t()) :: integer() | atom()
  def count(path) do
    path
    |> File.read()
    |> case do
      {:ok, binary} ->
        binary
        |> String.split("\n")
        |> Enum.count()

      {:error, error} ->
        Logger.error("#{@file_not_found_message}, code: #{error}")
        :error
    end
  end

  @doc """
  Migrate data from a file to the `plant traits` table. The file is read line by line
  to avoid loading the entire file into memory.

  Provide the absolute path of the file to migrate as the first parameter,
  optionally you can provide as second parameter the encoding mode of the file
  to migrate (see `encoding_mode()` type).


  ## Examples

      iex> Chirinola.Migrator.start("some_file.txt")
      "** MIGRATION FINISHED!"
      :ok

      iex> Chirinola.Migrator.start("some_file.txt", {:encoding, :utf8})
      "** MIGRATION FINISHED!"
      :ok

  If the path provided is incorrect an error will be displayed

  ## Examples

      iex> Chirinola.Migrator.start("bad_file.txt")
      `File not found, enter the absolute path of the file to migrate, code: enoent`
      :error

  """

  @spec start(String.t(), encoding_mode()) :: atom()
  def start(path, encoding_mode \\ @default_encoding)
  def start(nil, _encoding_mode), do: Logger.error(@wrong_path_message)
  def start("", _encoding_mode), do: Logger.error(@wrong_path_message)

  def start(_path, encoding_mode) when encoding_mode not in @valid_encondigs,
    do: Logger.error(@invalid_encoding_mode)

  def start(path, encoding_mode) do
    Logger.info("** MIGRATION PROCESS STARTED!")
    # path = "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
    # path = "/Users/ftitor/Downloads/17728_27112021022449/test.txt"

    path
    |> File.exists?()
    |> case do
      true ->
        Logger.info("** PROCESSING FILE (#{path})...")

        path
        |> File.stream!([encoding_mode], :line)
        |> Stream.map(&migrate_line/1)
        |> Stream.run()

        Logger.info("** MIGRATION FINISHED!")
        :ok

      false ->
        Logger.error(@file_not_found_message)
        :error
    end
  end

  defp migrate_line(line) when line == @headers_line,
    do: Logger.info("HEADERS REMOVED!")

  defp migrate_line(line) do
    line
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
