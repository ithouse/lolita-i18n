require 'active_record'

module Store
  class SQL_Migrations

    def self.create_table
      if ActiveRecord::Migration.table_exists?("translations")
        warn 'table alredy exists'
      else
        ActiveRecord::Migration.create_table(:translations, :options => "ENGINE=MEMORY" ) do |t| 
          t.string  :t_key
          t.string    :value
        end
        ActiveRecord::Migration.add_index :translations, [:t_key]
        return true
      end
    end


    def self.delete_table
      if ActiveRecord::Migration.table_exists?("translations")
        ActiveRecord::Migration.drop_table :translations
      else
        warn "table doesn't exists"
      end 
    end

  


  end
end
