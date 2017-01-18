defmodule Daychat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :chat_id, references(:chat, on_delete: :delete_all), null: false
      add :body, :text, null: false

      timestamps()
    end
    create index(:messages, [:user_id])
    create index(:messages, [:chat_id])
  end
end
