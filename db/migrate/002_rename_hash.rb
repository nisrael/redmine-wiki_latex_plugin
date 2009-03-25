class RenameHash < ActiveRecord::Migration
  def self.up
    rename_column :wiki_latexes, :hash, :image_id
    add_index :wiki_latexes, :image_id, :name => :wiki_latexes_image_id
  end

  def self.down
    rename_column :wiki_latexes, :image_id, :hash
  end
end
