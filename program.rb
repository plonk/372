class Program
  include Util

  def initialize(options)
    @options = options
    @filename = 'response_time.yml'
    @db = load_db
  end

  def load_db
    if File.exist? @filename
      hash = YAML.load File.read 'response_time.yml'
    else
      hash = {}
    end
    hash.default_proc = proc { [] }
    hash
  end

  def save_db(db)
    File.open(@filename, 'w') do |f|
      f.write YAML.dump db
    end
  end

  def practice(n)
    set = next_set(n)
    sleep 1
    wrongs = []
    set.each do |a, b|
      response = nil
      span = time do
        response = Readline.readline("#{a} * #{b} = ", true)
      end

      if response.to_i == a*b
        @db[[a,b]] += [span]
      else
        @db.delete([a,b])
        wrongs << [[a,b], response]
      end
    end

    if wrongs.any?
      wrongs.each do |(a,b), res|
        puts "#{a} * #{b} is equal to #{a*b} but you answered #{res}"
      end
    end
    save_db(@db)
  end

  def next_set req_num
    set = unpracticed.sample(req_num)
    print "#{set.size} unpracticed\n" if @options[:verbose]
    if set.size < req_num
      slow = @db.keys.sort_by { |key| @db[key].median }.last(req_num - set.size).reverse
      print "#{slow.size} slow\n" if @options[:verbose]
      set += slow
    end
    if set.size < req_num
      random = times_table.sample(req_num - set.size)
      print "#{random.size} random.\n" if @options[:verbose]
      set += random
    end
    set.shuffle
  end

  def unpracticed
    times_table.select {|a,b| @db[[a,b]].empty? }
  end

  def times_table
    @times_table ||= [*1..9].product([*1..9]).freeze
  end

  def min_mean_max(data)
    [:min, :mean, :max].map {|f| f.to_proc.call(data) }
  end

  def print_summary(field = :pair, reverse_order_p)
    puts "        Min/Mean/Max"

    keys = @db.keys.sort_by do |key|
      case field
      when :pair
        key
      else
        @db[key].send(field)
      end
    end

    keys.reverse! if reverse_order_p
    keys.each do |a, b|
      hist = @db[[a,b]]
      if hist.empty?
        puts "#{a} * #{b}: Unpracticed"
      else
        puts "#{a} * #{b}: %.2f/%.2f/%.2f\n" % min_mean_max(hist)
      end
    end
  end

  def print_stats
    if @db.empty?
      puts 'No stats available'
      return
    end

    min, mean, max = min_mean_max @db.values.flatten
    printf "#{@db.size} items practiced\n"
    printf "max: %.2f seconds\n", max
    printf "mean: %.2f seconds\n", mean
    printf "min: %.2f seconds\n", min
  end
end
