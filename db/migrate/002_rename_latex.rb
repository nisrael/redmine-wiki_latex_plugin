class RenameLatex < ActiveRecord::Migration
  def self.up
    rename_table :latex, :wiki_latex
  end

  def self.down
    rename_table :wiki_latex, :latex
  end
end
