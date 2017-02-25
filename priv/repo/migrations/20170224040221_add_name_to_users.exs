defmodule Daychat.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false, default: ""
    end

    alter table(:users) do
      modify :name, :string, default: nil
    end
  end
end
