# -*- coding: utf-8 -*-
=begin
3分間72問テスト
=end
require_relative 'deps'

class Cui < Thor
  class_option :verbose, type: :boolean

  desc 'practice [NUMBER]', 'Practice'
  def practice(number = "5")
    Program.new(options).practice(number.to_i)
  end

  desc 'summary [-r] [--sort=min/mean/max] [--reverse]', 'Print summary'
  method_options %w( sort ) => :string
  method_options %w( reverse r ) => :bool
  def summary
    Program.new(options).print_summary(options[:sort] || :pair, options[:reverse])
  end

  desc 'stats', 'Print statistics'
  def stats
    Program.new(options).print_stats
  end
end

Cui.start(ARGV)
