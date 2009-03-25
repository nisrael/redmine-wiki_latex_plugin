class RenameWikiLatex < ActiveRecord::Migration
  def self.up
    rename_table :wiki_latex, :wiki_latexes
  end

  def self.down
    rename_table :wiki_latexes, :wiki_latex
  end
end
