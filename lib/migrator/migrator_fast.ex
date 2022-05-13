defmodule Chirinola.MigratorFast do
  @moduledoc """
  Documentation for `MigratorFast` module.
  """

  require Logger
  alias Chirinola.PlantTrait

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

  # path = "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
  # path = "/Users/ftitor/Downloads/17728_27112021022449/test.txt"

  def start(_path, encoding_mode) when encoding_mode not in @valid_encondigs,
    do: Logger.error(@invalid_encoding_mode)

  def start(path, encoding_mode) do
    Logger.info("** MIGRATION PROCESS STARTED!")

    path
    |> File.exists?()
    |> case do
      true ->
        Logger.info("** PROCESSING FILE (#{path})...")

        path
        |> File.stream!([encoding_mode], :line)
        |> Stream.map(&process_line/1)
        |> Enum.to_list()
        |> Enum.reject(&(map_size(&1) == 0))
        |> insert_all()

        Logger.info("** MIGRATION FINISHED!")

      false ->
        Logger.error(@file_not_found_message)
        :error
    end
  end

  # process a line from the file
  defp process_line(line) when line == @headers_line, do: %{}
  defp process_line("\n"), do: %{}

  defp process_line(line) do
    line
    |> String.split("\n")
    |> Enum.at(0)
    |> String.split("\t")
    |> create_map()
  end

  defp create_map(plant) when length(plant) > 0 do
    datetime =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    Map.new()
    |> Map.put(:last_name, Enum.at(plant, 0))
    |> Map.put(:first_name, Enum.at(plant, 1))
    |> Map.put(:dataset_id, validate_integer(Enum.at(plant, 2)))
    |> Map.put(:dataset, Enum.at(plant, 3))
    |> Map.put(:species_name, Enum.at(plant, 4))
    |> Map.put(:acc_species_id, validate_integer(Enum.at(plant, 5)))
    |> Map.put(:acc_species_name, Enum.at(plant, 6))
    |> Map.put(:observation_id, validate_integer(Enum.at(plant, 7)))
    |> Map.put(:obs_data_id, validate_integer(Enum.at(plant, 8)))
    |> Map.put(:trait_id, validate_integer(Enum.at(plant, 9)))
    |> Map.put(:trait_name, Enum.at(plant, 10))
    |> Map.put(:data_id, validate_integer(Enum.at(plant, 11)))
    |> Map.put(:data_name, Enum.at(plant, 12))
    |> Map.put(:origl_name, Enum.at(plant, 13))
    |> Map.put(:orig_value_str, Enum.at(plant, 14))
    |> Map.put(:orig_unit_str, Enum.at(plant, 15))
    |> Map.put(:value_kind_name, Enum.at(plant, 16))
    |> Map.put(:orig_uncertainty_str, Enum.at(plant, 17))
    |> Map.put(:uncertainty_name, Enum.at(plant, 18))
    |> Map.put(:replicates, validate_float(Enum.at(plant, 19), :replicates))
    |> Map.put(:std_value, validate_float(Enum.at(plant, 20), :std_value))
    |> Map.put(:unit_name, Enum.at(plant, 21))
    |> Map.put(
      :rel_uncertainty_percent,
      validate_float(Enum.at(plant, 22), :rel_uncertainty_percent)
    )
    |> Map.put(:orig_obs_data_id, validate_integer(Enum.at(plant, 23)))
    |> Map.put(:error_risk, validate_float(Enum.at(plant, 24), :error_risk))
    |> Map.put(:reference, Enum.at(plant, 25))
    |> Map.put(:comment, Enum.at(plant, 26))
    |> Map.put(:no_name_column, Enum.at(plant, 27))
    |> Map.put(:inserted_at, datetime)
    |> Map.put(:updated_at, datetime)
  end

  defp create_map(_), do: %{}

  defp validate_integer(nil), do: nil
  defp validate_integer(""), do: nil
  defp validate_integer(number) when is_integer(number), do: number
  defp validate_integer(number) when is_binary(number), do: String.to_integer(number)

  defp validate_float(nil, _field), do: nil
  defp validate_float("", _field), do: nil
  defp validate_float(number, _field) when is_float(number), do: number

  defp validate_float(number, field) when is_binary(number) do
    number
    |> Float.parse()
    |> case do
      {float, _} ->
        float

      :error ->
        Logger.error("¡Error! Field: #{field}; Value: #{number}")
        nil
    end
  end

  defp validate_float(_, _), do: nil

  defp insert_all(list) do
    list
    |> Enum.chunk_every(2_000)
    |> Enum.each(&PlantTrait.insert_all/1)
  end
end
