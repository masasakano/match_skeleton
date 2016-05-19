# -*- encoding: utf-8 -*-

$stdout.sync=true
$stderr.sync=true
# print '$LOAD_PATH=';p $LOAD_PATH

arlibrelpath = []
arlibdir  = %w(match_skeleton)
arlibbase = ['']	# match_skeleton.rb is read.

arlibbase.each do |elibbase|
arlibdir.each do |elibdir|

  arAllPaths = []
  er=nil
  pathnow = nil
  # (['../lib/', 'lib/', ''].map{|i| i+elibbase+'/'} + ['']).each do |dir|
  ['../lib', 'lib', ''].each do |dirroot|
    begin
      s = [dirroot, elibdir, elibbase].join('/').sub(%r@^/@, '').sub(%r@/$@, '')
      # eg., %w(../lib/rangeary lib/rangeary rangeary)
      next if s.empty?
      arAllPaths.push(s)
      require s
      pathnow = s
      break
    rescue LoadError => er
    end
  end	# (['../lib/', 'lib/', ''].map{|i| i+elibbase+'/'} + '').each do |dir|

  if pathnow.nil?
    warn "Warning: All the attempts to load the following files have failed.  Abort..."
    warn arAllPaths.inspect
    warn " NOTE: It may be because a require statement in that file failed, 
rather than requiring the file itself.
 Check with  % ruby -r#{File.basename(elibbase)} -e p
 or maybe add  env RUBYLIB=$RUBYLIB:`pwd`"
    # p $LOADED_FEATURES.grep(/#{Regexp.quote(File.basename(elibbase)+'.rb')}$/)
    raise er
  else
    arlibrelpath.push pathnow
  end
end	# arlibdir.each do |elibdir|
end	# arlibbase.each do |elibbase|

print "NOTE: Library relative paths: "; p arlibrelpath
print "NOTE: Library full paths:\n"
arlibbase.each do |elibbase|
  fname = (elibbase.empty? ? arlibdir[0] : elibbase)	# Not complete.
  p $LOADED_FEATURES.grep(/#{Regexp.quote(File.basename(fname)+'.rb')}$/)
end


#################################################
# Unit Test
#################################################

require 'minitest/autorun'

class TestMatchSkeleton < Minitest::Test
  T = true
  F = false
  Inf = Float::INFINITY
  BS ||= "\u005c"
  BS_QUOTE ||= Regexp.quote(BS)

  def setup
    # @ib = 1
  end

  def teardown	# teardown is not often used.
    # @foo = nil
  end

  # # User method
  # def conjRE(r1, r2)
  #   Escape_Character.class_eval{ conjunctionRangeExtd(r1, r2) }
  # end

  def test_readme_example01
    str = "Something_Big."
    pos = 3
    mtch = str.match(/(.)big/i, pos)
    mskn = MatchSkeleton.new(mtch, str, pos_begin: pos)

    assert_equal true,  (mtch == mskn)
    assert_equal "Something_Big.", mskn.string
    assert_equal "_",   mskn[1]
    assert_equal 3,     mskn.pos_begin

    assert_equal ".",   mskn.post_match
    assert_equal ".",   mtch.post_match
    str[-1,1] = '%'
    assert_equal '%',   mskn.post_match
    assert_equal ".",   mtch.post_match
    assert_equal false, (mtch == mskn)
  end

  def test_string01
    # string(), regexp()
    s = 'abcdefghij'
    id = s.object_id
    re = /./i
    md = s.match(re)
    ms1 = MatchSkeleton.new(md, s)

    assert_equal s,  ms1.string
    assert_equal id, ms1.string.object_id
    assert_equal re, ms1.regexp
  end

  def test_pos_begin01
    s = 'abcdefghij'
    re = /g/i
    pos = 3
    md = s.match(re, pos)
    ms1 = MatchSkeleton.new(md, s, pos_begin: pos)

    assert_equal pos,  ms1.pos_begin
    ms1.pos_begin = 5
    assert_equal 5,    ms1.pos_begin
  end

  def test_equal01
    s = 'abcdefghij'
    re1 = /g/
    pos = 3

    md1 = s.match(re1, pos)
    ms1 = MatchSkeleton.new(md1, s, pos_begin: pos)
    assert_equal true,  (ms1 == md1)
    assert_equal true,  (md1 == ms1)
    assert_equal false, (ms1.eql?(md1))

    # pos_begin does not count.
    ms1p = ms1.dup
    assert_equal ms1.string.object_id, ms1p.string.object_id
    assert_equal true,  (ms1 == ms1p)
    assert_equal true,  (ms1.eql?(ms1p))
    ms1p.pos_begin = 6
    assert_equal true,  (ms1 == ms1p)
    assert_equal false, (ms1.eql?(ms1p))

    # Different Object-ID
    s2 = s.dup
    md2 = s2.match(re1, pos)
    ms21= MatchSkeleton.new(md2, s, pos_begin: pos)	# Equal but non-identical MatchData, but identical string s (with the identical Object-IDs)
    assert_equal true,  (ms1 == ms21)
    assert_equal true,  (ms1 == md2)
    assert_equal true,  (md2 == ms1)
    assert_equal true,  (ms21== md2)
    assert_equal true,  (md2 == ms21)
    assert_equal true,  (ms21.eql?(ms1))

    ms2 = MatchSkeleton.new(md2, s2, pos_begin: pos)	# Equal MatchData, but non-identical string s (with the different Object-IDs)
    assert_equal true,  (ms1 == ms2)
    assert_equal true,  (ms1 == md2)
    assert_equal true,  (ms2 == md2)
    assert_equal true,  (md2 == ms2)
    assert_equal false, (ms2.eql?(ms1))

    # Slightly different Regexp
    re3 = /g/i
    md3 = s.match(re3, pos)
    ms3 = MatchSkeleton.new(md3, s, pos_begin: pos)
    assert_equal false, (ms3 == ms1)

    # Different pre_match
    re4 = /./
    pos4 = 2
    md4 = s.match(re4, pos4)
    ms4 = MatchSkeleton.new(md4, s)
    pos5 = 6
    md5 = s.match(re4, pos5)
    ms5 = MatchSkeleton.new(md5, s)
    assert_equal false, (ms4 == ms5)
  end

  def test_squarebracket_single
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)	#=> #<MatchData "HX1138" 1:"H" 2:"X" 3:"113" 4:"8">
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1[0],   ms1[0]
    assert_equal "HX1138", ms1[0]
    assert_equal md1[1],   ms1[1]
    assert_equal "H",      ms1[1]
    assert_equal md1[3],   ms1[3]
    assert_equal "113",    ms1[3]
  end

  def test_squarebracket_double
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)	#=> #<MatchData "HX1138" 1:"H" 2:"X" 3:"113" 4:"8">
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1[1,2],     ms1[1, 2]
    assert_equal ["H", "X"],   ms1[1, 2]
    assert_equal md1[-3, 2],   ms1[-3, 2]
    assert_equal ["X", "113"], ms1[-3, 2]
  end

  def test_squarebracket_range
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)	#=> #<MatchData "HX1138" 1:"H" 2:"X" 3:"113" 4:"8">
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1[1..3],         ms1[1..3]
    assert_equal ["H", "X", "113"], ms1[1..3]
  end

  def test_squarebracket_name
    s = "ccaaab"
    md1 = /(?<foo>a+)b/.match(s)	#=> #<MatchData "aaab" foo:"aaa">
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1["foo"], ms1["foo"]
    assert_equal "aaa",      ms1["foo"]
    assert_equal md1[:foo],  ms1[:foo]
    assert_equal "aaa",      ms1[:foo]
    assert_raises(IndexError) { md1.begin(:naiyo) }
    assert_raises(IndexError) { ms1.begin(:naiyo) }
  end

  def test_begin_end_int01
    s ="THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.begin(0), ms1.begin(0)
    assert_equal md1.begin(2), ms1.begin(2)
    assert_equal md1.end(0),   ms1.end(0)
    assert_equal md1.end(2),   ms1.end(2)
    assert_equal 1, ms1.begin(0)
    assert_equal 2, ms1.begin(2)
    assert_equal 7, ms1.end(0)
    assert_equal 3, ms1.end(2)
  end

  def test_begin_end_int02
    s ="hoge"
    md1 = /(?<foo>.)(.)(?<bar>.)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.begin(:foo), ms1.begin(:foo)
    assert_equal md1.begin(:bar), ms1.begin(:bar)
    assert_equal md1.end(:bar),   ms1.end(:bar)
    assert_equal md1.end(:foo),   ms1.end(:foo)
    assert_equal 0, ms1.begin(:foo)
    assert_equal 2, ms1.begin(:bar)
    assert_equal 1, ms1.end(:foo)
    assert_equal 3, ms1.end(:bar)
    assert_raises(IndexError) { ms1.begin(:naiyo) }
    assert_raises(IndexError) { ms1.end(:naiyo) }
  end

  def test_captures01
    s ="THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.captures.size, ms1.captures.size
    assert_equal md1.captures,      ms1.captures
    assert_equal md1.captures[0],   ms1.captures[0]
    assert_equal ms1.captures[3],   ms1.captures[3]
    assert_equal 4,   ms1.captures.size
    assert_equal ms1.to_a[1..-1], ms1.captures
    assert_equal 'H', ms1.captures[0]
    assert_equal '8', ms1.captures[3]
  end

  def test_inspect01
    s ="foo"
    md1 = /.$/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal '#<MatchSkeleton "o">', ms1.inspect
  end

  def test_names01
    s = "hoge"
    md1 = /(?<foo>.)(?<bar>.)(?<baz>.)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.names, ms1.names
    assert_equal ["foo", "bar", "baz"], ms1.names

    s = "a"
    md1 = /(?<x>.)(?<y>.)?/.match(s)	#=> #<MatchData "a" x:"a" y:nil>
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.names,  ms1.names
    assert_equal ["x", "y"], ms1.names
  end

  def test_offset_int01
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.offset(0), ms1.offset(0)
    assert_equal md1.offset(4), ms1.offset(4)
    assert_equal [1, 7], ms1.offset(0)
    assert_equal [6, 7], ms1.offset(4)
  end

  def test_offset_name01
    s = "hoge"
    md1 = /(?<foo>.)(.)(?<bar>.)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.offset(:foo), ms1.offset(:foo)
    assert_equal md1.offset(:bar), ms1.offset(:bar)
    assert_equal [0, 1], ms1.offset(:foo)
    assert_equal [2, 3], ms1.offset(:bar)
    assert_raises(IndexError) { ms1.offset(:naiyo) }
  end

  def test_post_match01
    s = "THX1138: The Movie"
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.post_match, ms1.post_match
    assert_equal ": The Movie", ms1.post_match
  end

  def test_pre_match01
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.pre_match, ms1.pre_match
    assert_equal "T", ms1.pre_match
  end

  def test_size01
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.size,   ms1.size
    assert_equal md1.length, ms1.length
    assert_equal 5, ms1.size
    assert_equal 5, ms1.length
  end

  def test_to_a01
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.to_a, ms1.to_a
    assert_equal ["HX1138", "H", "X", "113", "8"], ms1.to_a
  end

  def test_to_s01
    s = "THX1138."
    md1 = /(.)(.)(\d+)(\d)/.match(s)
    ms1 = MatchSkeleton.new(md1, s)
    assert_equal md1.to_s, ms1.to_s
    assert_equal "HX1138", ms1.to_s
    assert_equal ms1.to_a[0], ms1.to_s
    assert_equal ms1[0], ms1.to_s
  end

end	# class TestMatchSkeleton < Minitest::Test


