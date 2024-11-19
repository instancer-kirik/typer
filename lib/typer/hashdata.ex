defmodule Typer.HashData do
  alias Typer.Repo
  alias Typer.Game.Hash


  def save_hash(attrs) do

    case attrs[:hash] do
      nil ->
        {:error, :invalid_hash}
      hash_value ->
        existing_hash = Repo.get_by(Hash, hash: hash_value)
        case existing_hash do
          nil ->
            case %Hash{} |> Hash.changeset(attrs) |> Repo.insert() do
              {:ok, hash_data} ->
                {:ok, hash_data}  # Explicitly handling the success case
              {:error, changeset} ->
                {:error, changeset}
            end

          _existing ->
            {:error, {:exists, attrs[:app_title]}}
        end
    end
  end
  # def save_hash(attrs \\ %{}) do
  #   # query = from h in Hash, where: h.hash == ^attrs["hash"]
  #   # existing_hash = Repo.one(query)
  #   existing_hash = Repo.get_by(Hash, hash: attrs["hash"])
  #   case existing_hash do
  #     nil ->
  #       case %Hash{} |> Hash.changeset(attrs) |> Repo.insert() do
  #         {:ok, hash_data} -> {:ok, hash_data}
  #         {:error, changeset} -> {:error, changeset}
  #       end

  #     _existing ->
  #       {:error, :exists}
  #   end
    # case existing_hash do
    #   nil ->
    #     %Hash{}
    #     |> Hash.changeset(attrs)
    #     |> Repo.insert()

    #   _existing ->
    #     {:error, :exists}
    # end
    # case existing_hash do
    #   nil ->
    #     %Hash{}
    #     |> Hash.changeset(attrs)
    #     |> Repo.insert()
    #     |> case do
    #          {:ok, hash_data} -> {:ok, hash_data}
    #          {:error, changeset} -> {:error, changeset}
    #        end

    #   _hash ->
    #     {:error, :exists}
    # end
  end
  # def save_hash(attrs \\ %{}) do
  #   %Hash{}
  #   |> Hash.changeset(attrs)
  #   |> HashRepo.insert()
  # end
  # def save_hash(hash_params) do
  #   %Hash{}
  #   |> Hash.changeset(hash_params)
  #   |> HashRepo.insert()
  # end
