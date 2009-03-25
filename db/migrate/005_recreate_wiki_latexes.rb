class RecreateWikiLatexes < ActiveRecord::Migration
  def self.up
    drop_table :wiki_latexes
    create_table :wiki_latexes do |t|
      t.column :id, :string, :limit => 64, :null => false
      t.column :source, :text, :null => false
    end    
    add_index :wiki_latexes, :id, :name => :wiki_latexes_id
  end

  def self.down
  end
end
