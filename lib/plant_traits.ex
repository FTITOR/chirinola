defmodule Chirinola.PlantTrait do
  @moduledoc """
  Documentation for `PlantTrait` module.
  """

  require Logger
  alias Chirinola.Repo
  alias Chirinola.Schema.PlantTraits, as: PlantTraitsSchema

  @doc """

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
        Logger.error("## PARAMS")
        Logger.info(plant_traits_attrs)
        Logger.error("## INFORMATION TO INSERT:")
        Logger.info(changes)
        Logger.error("## ERROR DETAIL:")
        Logger.info(error)
        File.write("errors.text", changes)
        error
    end
  end

  @doc """

  """
  @spec insert_all(list()) :: {number(), list()} | nil
  def insert_all(plant_traits_attrs) do
    PlantTraitsSchema
    |> Repo.insert_all(plant_traits_attrs)
  end
end
