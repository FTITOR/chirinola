defmodule Chirinola.Migrator do
  @moduledoc """
  Documentation for `Migrator` module.
  """
  require Logger
  alias Chirinola.{QueueManager, Worker}

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

  @n_processes 1..200
  @file_not_found_message "File not found, enter the absolute path of the file to migrate"

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

  # path = "/Users/ftitor/Downloads/17728_27112021022449/17728.txt"
  # path = "/Users/ftitor/Downloads/17728_27112021022449/test.txt"

  @spec start(String.t(), encoding_mode()) :: atom()
  def start(path, encoding_mode \\ @default_encoding)
  def start(nil, _encoding_mode), do: Logger.error(@wrong_path_message)
  def start("", _encoding_mode), do: Logger.error(@wrong_path_message)

  def start(_path, encoding_mode) when encoding_mode not in @valid_encondigs,
    do: Logger.error(@invalid_encoding_mode)

  def start(path, encoding_mode) do
    Logger.info("** MIGRATION PROCESS STARTED!")

    path
    |> File.exists?()
    |> case do
      true ->
        Logger.info("** PROCESSING FILE (#{path})...")
        queue_pid = setup_processes()

        path
        |> File.stream!([encoding_mode], :line)
        |> Stream.map(&process_line(&1, queue_pid, Path.basename(path)))
        |> Stream.run()

        Logger.info("** MIGRATION FINISHED!")
        :ok

      false ->
        Logger.error(@file_not_found_message)
        :error
    end
  end

  defp process_line(line, queue_pid, file_name) do
    {:ok, worker_pid} = QueueManager.get_pid(queue_pid)
    Worker.insert(worker_pid, line, file_name)
  end

  defp setup_processes() do
    {:ok, queue_pid} = QueueManager.start_link()

    @n_processes
    |> Enum.to_list()
    |> Enum.each(fn _ ->
      {:ok, worker_pid} = Worker.start_link()
      QueueManager.push(queue_pid, worker_pid)
    end)

    queue_pid
  end
end
