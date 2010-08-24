connection = ActiveRecord::Base.connection
class << connection
  alias :original_exec :execute
  
  begin
    @@host = `uname -n`.strip
  rescue
    @@host = `hostname`
  end

  # Staging or local
  @@acceptable_hosts = [ 'ey01-s00093' ]
  #@@acceptable_hosts = [ 'ey01-s00093', 'suttree.local' ]

  def execute(query, *name)
    mysql_result = original_exec(query, *name)
    if @@acceptable_hosts.include? @@host
      original_exec( "INSERT INTO sql_profiler( `query`, `num_rows` ) VALUES ( \"#{query}\", #{mysql_result.num_rows} )" ) rescue nil
    end
    mysql_result
  end
end