class CreateLatex < ActiveRecord::Migration
  def self.up
    create_table :latex do |t|
      t.column :latex_id, :string, :limit => 64, :null => false
      t.column :source, :text, :null => false
    end    
    add_index :latex, :latex_id, :name => :latex_latex_id
  end

  def self.down
    drop_table :latex
  end
end
