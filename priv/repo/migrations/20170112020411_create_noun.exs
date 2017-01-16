defmodule Daychat.Repo.Migrations.CreateNoun do
  use Ecto.Migration

  def change do
    create table(:nouns) do
      add :word, :string, null: false, size: 32
      add :weight, :integer, null: false, default: 0

      timestamps null: false
    end

    create index(:nouns, [:weight])
    create unique_index(:nouns, [:word])
  end
end
