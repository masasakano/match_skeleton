# -*- coding: utf-8 -*-

require 'match_skeleton/match_data'

# =Class MatchSkeleton
# 
# To represent {MatchData} with much less memory use
# 
class MatchSkeleton

  # The same as {MatchData#string} but it is identical to the original string.
  # If the original string is modified destructively, this too is modified.
  attr_reader :string

  # The same as {MatchData#regexp}.
  attr_reader :regexp

  # The position {Regexp} match has started.
  # For example, both
  #   /x/.match('0000x', 0)
  #   /x/.match('0000x', 3)
  # give the same (equal) {MatchData}.  This instance variable {#pos_begin}
  # holds the position (0 or 3 in the cases above), if set explicitly.
  attr_accessor :pos_begin


  # @param md [MatchData]
  # @param string [String] If not specified, it is taken from the first argument (however, that would spoil the whole point of using this class!)
  # @param pos_begin: [Integer] The position {Regexp} match has started.
  def initialize(md, string=nil, pos_begin: nil)
    size_str = md.string.size
    if string && string.size != size_str
      raise ArgumentError, 'The first parameter is obligatory.'
    end
    @string = (string || md.string)
    @regexp = md.regexp
    @pre_match  = (0..(md.pre_match.size-1))	# {Range}
    @post_match = ((size_str-md.post_match.size)..(size_str-1))	# {Range}

    # @offsets is Hash with the keys of both Integer and possibly Symbol
    # if names exist.
    names  = md.names
    ar_off = (0..(md.size-1)).map do |n|
      ar = md.offset(n)
#if names[0]=='foo'
#print "DEBUG: ar=#{ar.inspect}\n"
#printf "DEBUG: n=(%d)range=%s\n", n, (ar.first...ar.last).inspect
#end
      (ar.first...ar.last)
    end
    @offsets = {}
    ar_off.each_with_index do |ev, ei|
      @offsets[ei] = ev
      ej = ei - 1
      @offsets[names[ej]] = ev if (ej >= 0 && names[ej])
#print "DEBUG: names=#{names[ei].inspect}\n"
#p names[ei], ev
#p md.offset(:foo)
    end
#printf "DEBUG: offsets=%s\n", @offsets.inspect if !names.empty?
    

    @pos_begin = pos_begin
  end

  # Comparable with {MatchSkeleton} and {MatchData}
  #
  # A difference in {#pos_begin} is not taken into account.
  #
  # @param [Object] The methods of {#string}, {#regexp}, {#pre_match} have to be defined and return the same to be true. Practically, only {MatchSkeleton} and {MatchData} may return true.
  # @return [Boolean]
  # @see #eql?
  def ==(obj)
    (string    == obj.string) &&
    (regexp    == obj.regexp) &&
    (pre_match == obj.pre_match)
  end

  # The same as {MatchData#[]}
  #
  # @param i [Integer, Range, Symbol, String]
  # @param j [Integer, NilClass]
  # @return [String, Array, NilClass]
  # @raise [IndexError] if an invalid argument(s) is given.
  def [](i, j=nil)
    if j
      to_a[i, j]
    elsif defined?(i.to_sym)
      values_at(i)[0]
    else
      to_a[i]
    end
  end

  # The same as {MatchData#begin}
  #
  # @param n [Integer]
  # @return [Integer]
  def begin(n)
    offset(n)[0]
  end

  # The same as {MatchData#captures}
  #
  # @return [Array]
  def captures
    to_a[1..-1]
  end

  # The same as {MatchData#end}
  #
  # @param n [Integer]
  # @return [Integer]
  def end(n)
    offset(n)[1]
  end

  # The same as {#==} but stricter comparison.
  #
  # The comparison between {MatchSkeleton} and {MatchData} returns false and
  # that between {MatchSkeleton} with different {#pos_begin} or
  # those with strings of different Object-IDs also return false.
  #
  # @param [Object]
  # @return [Boolean]
  # @see #==
  def eql?(obj)
    return false if self != obj
    return false if !defined?(obj.pos_begin)
    return false if (string.object_id != obj.string.object_id)
    return false if pos_begin != obj.pos_begin
    return true
  end

  # Similar to {MatchData#inspect}
  #
  # @return [String]
  def inspect
    core = ''
    ar = (names.empty? ? captures : names)
    ar.each_with_index do |ev, ei|
      core << sprintf(" %d:%s", ei, ev.inspect)
    end
    sprintf("#<%s %s%s>", self.class.to_s, self[0].inspect, core)
  end

  # The same as {MatchData#names} and {Regexp#names}
  #
  # @return [Array<String>]
  def names
    regexp.names
  end

  # The same as {MatchData#offset}
  #
  # @param n [Integer]
  # @return [Array<integer>]
  def offset(n)
    if defined?(n.to_sym)
      n = n.to_s 
      raise IndexError, sprintf("undefined group name reference: %s", n) if !names.include?(n)
    end
    [@offsets[n].first, 
     @offsets[n].last]
  end

  # The same as {MatchData#pre_match}
  #
  # @return [String]
  def pre_match
    @string[@pre_match]
  end

  # The same as {MatchData#post_match}
  #
  # @return [String]
  def post_match
    @string[@post_match]
  end

  # The same as {MatchData#size}
  #
  # @return [Integer]
  def size
    to_a.size
  end
  alias_method :length, :size if ! self.method_defined?(:length)

  # The same as {MatchData#to_a}
  #
  # @return [Array]
  def to_a
#print 'DEBUG: '; p @offsets
    indices = @offsets.keys.sort
    indices.delete_if { |i| !defined?(i.divmod) }
    indices.map { |i| string[@offsets[i]] }
  end

  # The same as {MatchData#to_s}
  #
  # @return [String]
  def to_s
    self[0]
  end

  # The same as {MatchData#values_at}
  #
  # @param *rest [Integer, Symbol, String]
  # @return [Array]
  def values_at(*rest)
    rest.map do |i|
      key = @offsets[i.to_s]
#    printf "DEBUG(%s): offsets=%s string=%s i=%s key=%s r=%s\n", __method__, @offsets.inspect,string.inspect,i.inspect,key.inspect,(string[key].inspect rescue 'nil') if !names.empty?
      raise IndexError, sprintf("undefined group name reference: %s", i) if !key
      string[key]
    end
  end
end
