require 'active_record'
module Store

class SQL_Migrations
  def self.create_table
        
    if ActiveRecord::Migration.table_exists?("translations")
      warn 'table alredy exists'
    else
      ActiveRecord::Migration.create_table(:translations) do |t| #, :options => "ENGINE=MEMORY"
          t.string  :key
          t.string    :value
      end
       ActiveRecord::Migration.add_index :translations, [:key], :unique => true
      return true
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

end

 # create_table(:translations, :options => "ENGINE=MEMORY") do |t|
 #      t.string  :locale
 #      t.string  :key
 #      t.text    :value
 #      t.text    :interpolations
 #      t.boolean :is_proc, :default => false

 #      t.timestamps
 #    end

 #    add_index :translations, [:locale, :key], :unique => true
 #  end