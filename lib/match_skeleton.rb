# -*- coding: utf-8 -*-

begin
  require 'match_skeleton/match_data'
rescue LoadError
  if !MatchData.method_defined? :equal_before_match_skeleton
    # Probably this file is read with its absolute path explicitly specified.
    msg = 'WARNING(LoadError): "match_skeleton/match_data" - the library path to %s is not correctly set and hence failed to read some methods.'%(File.basename __FILE__)
    warn msg
  end
end

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


  # Constructor
  #
  # If the second argument is omitted, it is taken from the first argument
  # with +MatchData#string+. However, it would spoil the whole point of
  # using this class, given +MatchData#string+ always "dups" the original
  # string and uses up extra memory space!  If you do not specify the second
  # argument, this class offers almost identical functions but works slower,
  # save from the bonus information of pos_begin, which can be added in this
  # initialization in this class.
  #
  # The point of using this class is to save the memory when you make multiple
  # applications with many Regexp to the identical instance of String (with
  # the same object_id) *and* if you want to keep the results of the Regexp
  # match as MatchData or equivalent.  So, do not forget to specify the second
  # argument in this initialization!
  #
  # @param md [MatchData]
  # @param string [String] If not specified, it is taken from the first argument.
  # @param pos_begin: [Integer] The position where {Regexp} match has started.
  def initialize(md, string=nil, pos_begin: nil)
    size_str = md.string.size
    if string && string.size != size_str
      raise ArgumentError, 'The first parameter is obligatory.'
    end
    @string = (string || md.string)
    @regexp = md.regexp
    @pre_match  = (0...md.pre_match.size)	# {Range}
    @post_match = ((size_str-md.post_match.size)...size_str)	# {Range}

    # @offsets is Hash of Range-s with the keys of both Integer and possibly Symbol
    # if names exist.
    names  = md.names
    ar_off = (0..(md.size-1)).map do |n|
      ar = md.offset(n)
      (ar.first...ar.last)
    end
    @offsets = {}
    ar_off.each_with_index do |ev, ei|
      @offsets[ei] = ev
      ej = ei - 1
      @offsets[names[ej]] = ev if (ej >= 0 && names[ej])
    end

    @pos_begin = pos_begin
  end

  # Comparable with {MatchSkeleton} and {MatchData}
  #
  # A difference in {#pos_begin} is not taken into account.
  #
  # @param obj [Object] The methods of {#string}, {#regexp}, {#pre_match} have to be defined and return the same to be true. Practically, only {MatchSkeleton} and {MatchData} may return true.
  # @return [Boolean]
  # @see #eql?
  def ==(obj)
    !!((defined?(obj.string)     && string     == obj.string) &&
       (defined?(obj.regexp)     && regexp     == obj.regexp) &&
       (defined?(obj.pre_match)  && pre_match  == obj.pre_match) &&
       (defined?(obj.post_match) && post_match == obj.post_match))
    # nb., defined?() can return nil, and then nil (not false) will be returned.
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
      i = i.to_s
      raise IndexError, sprintf("undefined group name reference: %s", i) if !names.include?(i)
      offset2string(i)
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

  # # The same as {#==} but stricter comparison.
  # #
  # # The comparison between {MatchSkeleton} and {MatchData} returns false and
  # # that between {MatchSkeleton} with different {#pos_begin} or
  # # those with strings of different Object-IDs also return false.
  # #
  # # @param obj [Object]
  # # @return [Boolean]
  # # @see #==
  # def eql?(obj)
  #   return false if self != obj
  #   return false if !defined?(obj.pos_begin)
  #   return false if (string.object_id != obj.string.object_id)
  #   return false if pos_begin != obj.pos_begin
  #   return true
  # end

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
  # Due to the change in Ruby 2.6
  # https://rubyreferences.github.io/rubychanges/2.6.html#endless-range-1
  # the old routines would raise an Excetion when the end range is nil,
  # that is, there is no match for MatchData#[n], hence needed updating.
  #
  # @param n [Integer]
  # @return [Array<integer>]
  def offset(n)
    if defined?(n.to_sym)
      n = n.to_s 
      raise IndexError, sprintf("undefined group name reference: %s", n) if !names.include?(n)
    end

    ## This used to work before Ruby 2.6
    # [@offsets[n].first, 
    #  @offsets[n].last]

    [:first, :last].map do |ec|
      begin
        @offsets[n].public_send ec
      rescue RangeError
        nil
      end
    end
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
    indices = @offsets.keys.sort
    indices.delete_if { |i| !defined?(i.divmod) }
    indices.map { |i| offset2string(i) }
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
    locary = to_a
    rest.map do |i|
      locary[i]
    end
  end

  ######################### private #########################

  private 

  # @note Due to the change in Ruby 2.6, k.last may raise RangeError.
  #   In this instance, k.first must be always nil when k.last is nil.
  #   So, k.last would not be evaluated when k.last is nil.
  #   But it is playing safe (by adding "rescue").
  def offset2string(i)
    k = @offsets[i]
    (k.first && (k.last rescue nil)) ? string[k] : nil
  end
end	# class MatchSkeleton
