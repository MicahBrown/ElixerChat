defmodule Daychat.Repo.Migrations.CreateChat do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :string, null: false, size: 32
      add :auth_key, :string, null: false, size: 128
      add :participants_count, :integer, null: false, default: 0

      timestamps(null: false)
    end

    create index(:chats, [:user_id])
    create unique_index(:chats, [:token])
    create unique_index(:chats, [:auth_key])
  end
end
