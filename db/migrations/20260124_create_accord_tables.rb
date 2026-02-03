Sequel.migration do
  change do
    create_table(:provider_contracts) do
      primary_key :id
      foreign_key :provider_id, :pacticipants, null: false
      String :version_number, null: false
      String :content, text: true, null: false
      String :content_type, default: 'application/yaml'
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    create_table(:users) do
      primary_key :id
      String :email, null: false, unique: true
      String :name
      DateTime :last_login
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    create_table(:permissions) do
      primary_key :id
      String :resource_type
      Integer :resource_id
      foreign_key :user_id, :users, null: false
      String :access_level
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
