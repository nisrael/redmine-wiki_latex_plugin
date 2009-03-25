class CreateWikiLatexes < ActiveRecord::Migration
  def self.up
    create_table :wiki_latexes do |t|
      t.column :hash, :string, :limit => 64, :null => false
      t.column :source, :text, :null => false
    end    
    add_index :wiki_latexes, :hash, :name => :wiki_latexes_hash
  end

  def self.down
    drop_table :wiki_latexes
  end
end
