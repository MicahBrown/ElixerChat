defmodule Daychat.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :token, :string, null: false, size: 32
      add :auth_key, :string, null: false, size: 128

      timestamps null: false
    end

    create unique_index(:users, [:token])
    create unique_index(:users, [:auth_key])
  end
end
