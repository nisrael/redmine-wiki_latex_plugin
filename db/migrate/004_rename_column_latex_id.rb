class RenameColumnLatexId < ActiveRecord::Migration
  def self.up
    rename_column :wiki_latexes, :latex_id, :hash
    add_index :wiki_latexes, :hash, :name => :wiki_latexes_hash
  end

  def self.down
    rename_column :wiki_latexes, :hash, :latex_id
  end
end
