defmodule Daychat.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false, size: 32
      add :token, :string, null: false, size: 128

      timestamps null: false
    end

    create unique_index(:users, [:name])
    create unique_index(:users, [:token])
  end
end
