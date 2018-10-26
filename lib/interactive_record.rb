require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    table_info.map {|row|
        row["name"]
    }.compact
  end

  def initialize(hash={})
    hash.each {|k, v| self.send("#{k}=", v)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
  #  binding.pry
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_names|
      #binding.pry
      values << "'#{send(col_names)}'" unless send(col_names).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by( hash )
    where_str = hash.map{|k,v| "#{k}= '#{v}'"}.join(" AND ")
#binding.pry
    sql = "SELECT * FROM #{self.table_name} WHERE " + where_str
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}';"
    row = DB[:conn].execute(sql)

  end
end
