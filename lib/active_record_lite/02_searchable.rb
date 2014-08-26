require_relative 'db_connection'
require_relative '01_sql_object'

#this is a module, so make sure what you write in here is flexible.
module Searchable
  def where(params)
    where_line = params.map { |attr_name| "#{attr_name} = ?" }.join(" AND ")
    results = DBConnection.execute(<<-SQL, )
    SELECT
    *
    FROM
    
    
    SQL
    # ...
  end
end

class SQLObject
  # Mixin Searchable here...
end
