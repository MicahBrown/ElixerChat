defmodule Daychat.Repo.Migrations.CreateParticipant do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :chat_id, references(:chats, on_delete: :delete_all)
      add :position, :integer, null: false, default: 0

      timestamps null: false
    end

    create index(:participants, [:user_id])
    create index(:participants, [:chat_id])
    create unique_index(:participants, [:user_id, :chat_id])
    create unique_index(:participants, [:chat_id, :position])
  end
end
