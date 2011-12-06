class Map
  attr_reader :collection, :collection_name, :columns, :rows, :table, :stat_rows
  def initialize(collection)
    @collection = collection
    
  end
  
  def count_by(item)
    m = "function(){
        emit(this.ITEM, 1);
        }"
    m.gsub!("ITEM", item)
    r = reduce_count
    @collection.map_reduce(m,r,{:out =>"output"})
    
  end
  
  def collection_name 
    @collection_name = @collection.name
  end
  
  def count_item_by_day(item)
        #day = formatDate(this.at.getDate());
    m = "function(){
        day = Date.UTC(this.at.getFullYear(), this.at.getMonth(), this.at.getDate());
        
        emit({day: day, station: this.station}, 1);
        }"
    m.gsub!("ITEM", item)
    r = reduce_count
    
    output = @collection.map_reduce(m,r, {:out => "output"})
    @columns = output.distinct("_id.day")
    @rows = output.distinct("_id." + item)

    @table = Hash.new

    output.find().each do |line|
     row_col = line["_id"]
     row = row_col[item]
     col = row_col["day"]
     @table[[row, col]] = line["value"].to_i
    end
     
  end
    
  
  def group_by_count(item1, item2)
    m = "function(){
          emit({" + item1 + " : this." + item1 + ", " +
                    item2 + " : this." + item2 +
              "},
            1);
          }"
    
   r = reduce_count    
   output = @collection.map_reduce(m,r, {:out => "results"})
   @columns = output.distinct("_id." + item2)
   @rows = output.distinct("_id." + item1)
   
   @table = Hash.new
 
   output.find().each do |line|
     row_col = line["_id"]
     row = row_col[item1]
     col = row_col[item2]
     @table[[row, col]] = line["value"].to_i
   end
   
   
   return @table
  end
    
               
  def table_stats
    @stat_rows = ["min", "max", "total", "mean", "median", "stdev"]
    @stats = Hash.new
    @columns.each do |col|
      @numbers = Array.new
      @rows.each do |row|
        @numbers << @table[[row,col]]
      end
      
      # Remove nils
      @numbers.delete_if {|x| x == nil}
      @numbers.sort!
      @stats[["min", col]] = @numbers[0]
      @stats[["max", col]] = @numbers[-1]
      @stats[["total", col]] = @numbers.sum
      @stats[["mean", col]] = @numbers.sum / @numbers.length
      
      #median takes a little more work.
      median = 0
      n = (@numbers.length - 1) / 2 # Middle of the array
      n2 = (@numbers.length) / 2 # Other middle of the array.
                                                # Used only if amount in array is even
      if @numbers.length % 2 == 0 # If number is even
       median = (@numbers[n] + @numbers[n2]) / 2
      else
       median = @numbers[n]
      end
      @stats[["median", col]] = median
      
      @stats[["stdev", col]] = standard_deviation(@numbers).to_i
      
        
    end
      
    return @stats
    
  end
    
  
  def reduce_count()
     r = "function(k, vals){
       var sum = 0;
       vals.forEach(function(val) {
         sum += val;
         });
       return sum;
       };"
  end
    
  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    # if you want to calculate std deviation
    # of a sample change this to "s / (n-1)"
    return s / n
  end

  # calculate the standard deviation of a population
  # accepts: an array, the population
  # returns: the standard deviation
  def standard_deviation(population)
    Math.sqrt(variance(population))
  end
  
  
  
end

