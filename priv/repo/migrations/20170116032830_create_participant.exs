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


# create_table :participants do |t|
#   t.belongs_to :user,     null: false
#   t.belongs_to :chat,     null: false
#   t.integer    :position, null: false, default: 0
#   t.timestamps            null: false
# end

# add_index :participants, [:user_id, :chat_id], unique: true
# add_index :participants, [:chat_id, :position], unique: true
# add_foreign_key :participants, :chats, on_delete: :cascade
# add_foreign_key :participants, :users, on_delete: :cascade