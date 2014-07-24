# -*- coding: utf-8 -*-
=begin
3分間72問テスト
=end
require_relative 'deps'

class Program
  include Util

  def initialize
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
    next_set(n).each do |a, b|
      response = nil
      span = time do
        response = Readline.readline("#{a} * #{b} = ", true)
      end

      if response.to_i == a*b
        @db[ [a,b] ] += [span]
      end
    end
    save_db(@db)
  end

  def next_set n
    set = unpracticed.sample(n)
    set += times_table.sample(n - set.size) if set.size < n
    set
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

    printf "#{@db.size} items practiced\n"
    printf "max: %.2f seconds\n", @db.values.flatten.max
    printf "mean: %.2f seconds\n", @db.values.flatten.mean
    printf "min: %.2f seconds\n", @db.values.flatten.min
  end
end

class Cui < Thor
  desc 'practice [NUMBER]', 'Practice'
  def practice(number = "5")
    Program.new.practice(number.to_i)
  end

  desc 'summary [-r] [--sort=min/mean/max] [--reverse]', 'Print summary'
  method_options %w( sort ) => :string
  method_options %w( reverse r ) => :bool
  def summary
    Program.new.print_summary(options[:sort] || :pair, options[:reverse])
  end

  desc 'stats', 'Print statistics'
  def stats
    Program.new.print_stats
  end
end

Cui.start(ARGV)
