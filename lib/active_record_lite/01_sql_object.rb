require_relative 'db_connection'
require 'active_support/inflector'
#NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
#    of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns.nil? #fetch only if we don't have any columns
      columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
        LIMIT
          0
        SQL
      @columns = columns[0].map(&:to_sym)
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |column|

      define_method "#{column}" do
        self.attributes[column]
      end

      define_method("#{column}=") do |arg|
        self.attributes[column] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
    # ...
  end

  def self.all
    all_records = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(all_records) #array of hashes
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)  #make new objects of self
    end
    # ...
  end

  def self.find(id)
    #inefficient way
    # self.all.find{ |obj| obj.id = id }


    #my way?
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    WHERE
      #{self.table_name}.id = ?
    SQL

    self.parse_all(results).first
    # ...
  end

  def attributes
    @attributes ||= {}

    # ...
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * attribute_values.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{ self.class.table_name } (#{ col_names })
      VALUES
        (#{ question_marks })
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name) #you have to do self.class because 
                                                #columns is a class method
        self.send("#{attr_name}=", value) #you have to use send here so you can pass 
                                          #an arbitrary method call "attr_name"
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end

    # ...
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
    # ...
  end


  #how does the order of the attribute_values line up with the attr_name?
  def update
    column_sets = self.class.columns.map { |attr_name| "#{attr_name} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column_sets}
      WHERE
        #{self.class.table_name}.id = ?
      SQL
    # ...
  end 

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
    # ...
  end
end








