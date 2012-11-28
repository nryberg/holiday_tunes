class Map
  attr_reader :collection, :collection_name, :columns, :rows, :table, :stat_rows, :count, :database, :output
  def initialize(collection)
    @collection = collection
    @database = @collection.db
    
  end
  
  def count()
    @collection.count
  end


  def count_by(item, output = "output", filter_by = nil, filter_value = nil)
    m = "function(){
        emit(this.ITEM, 1);
        }"
    m.gsub!("ITEM", item)
    r = reduce_count

    if filter_by.nil? then
      @collection.map_reduce(m,r,{:out =>output})
    else
      @collection.map_reduce(m,r,{:out =>output, :query =>{filter_by => filter_value}})
    end

    add_index_to_collection(output)
    @database[output]
    
  end


  def add_index_to_collection(collection_name)
    counter = 0
    collection = @database[collection_name]
    max = collection.count
    collection.find().each do |doc| 
      if doc[:lookup].nil? then 
        doc[:lookup] = "c_" + counter.to_s
        collection.save(doc, :safe => true)
        counter += 1
      end
      if count > max then ap "What the fuck?" end
    end
  end

  def count_by_filtered(item, filter, filter_by)
    m = "function(){
        emit(this.ITEM, 1);
        }"
    m.gsub!("ITEM", item)
    r = reduce_count
    @collection.map_reduce(m,r,{:out =>"output", :query =>{filter_by => filter}})

    add_index_to_collection("output")
    
  end
 
  def collection_name 
    @collection_name = @collection.name
  end
  
  def count_item_by_day(item)
        #day = formatDate(this.at.getDate());
    m = "function(){
        day = Date.UTC(this.at.getUTCFullYear(), this.at.getUTCMonth(), this.at.getUTCDate());
        
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

  def group_by(item, filter_by = nil, filter_value = nil)
    @collection.group({:key => item}, 
                      nil, 
                      {:count => 0},
                      "function(x,y){y.count++}"
                      )
  end  
  
  def group_by_count(item1, item2, output = "results", filter_by = nil, filter_value = nil)
    m = "function(){
          emit({" + item1 + " : this." + item1 + ", " +
                    item2 + " : this." + item2 +
              "},
            1);
          }"
    
   r = reduce_count    

   if filter_by.nil? then
    output = @collection.map_reduce(m,r, {:out => output})
    else
    output = @collection.map_reduce(m,r, {:query => {filter_by => filter_value}, :out => output})

   end
 
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
       return (sum);
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

