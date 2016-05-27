# -*- coding: utf-8 -*-

# =Class MatchData
# 
# Modifies the operator {#==} so it can be compared with {MatchSkeleton}.
# 
class MatchData

  # Backup alias for {MatchData#==}
  alias_method :equal_before_match_skeleton, :== if ! self.method_defined?(:equal_before_match_skeleton)

  # Compares with {MatchSkeleton}, in addition to {MatchData}
  #
  # @param [#string, #regexp, #pre_match] All the methods have to be there. Practically, {MatchSkeleton} and {MatchData}
  # @return [Boolean]
  def ==(obj)
    !!((defined?(obj.string)    && string    == obj.string) &&
       (defined?(obj.regexp)    && regexp    == obj.regexp) &&
       (defined?(obj.pre_match) && pre_match == obj.pre_match))
    # nb., defined?() can return nil, and then nil (not false) will be returned.
  end

end
