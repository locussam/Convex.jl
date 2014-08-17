#############################################################################
# dcp.jl
# This file handles the basic rules on interactions of mathematical expressions
# to create new expressions.
#
# For example: negative of a concave expression is convex, or multiplication
# of two positive expressions continue to be positive.
#
# See: http://dcp.stanford.edu/rules or the original paper at
# http://web.stanford.edu/~boyd/papers/disc_cvx_prog.html
#############################################################################

export Vexity, ConstVexity, Affine, Convex, Concave, NotDcp
export Monotonicity, Nonincreasing, Nondecreasing, NoMonotonicity
export Sign, Positive, Negative, NoSign, Semidefinite
export -, +, *

# Vexity subtypes
abstract Vexity
type ConstVexity <: Vexity              end
type Affine <: Vexity                   end
type Convex <: Vexity                   end
type Concave <: Vexity                  end
type NotDcp <: Vexity                 end

# Monotonocity subtypes
abstract Monotonicity
type Nonincreasing <: Monotonicity      end
type Nondecreasing <: Monotonicity      end
type ConstMonotonicity <: Monotonicity  end
type NoMonotonicity <: Monotonicity     end

# Sign subtypes
abstract Sign
type Positive <: Sign                   end
type Negative <: Sign                   end
type NoSign <: Sign                     end
type Semidefinite <: Sign               end

-(v::Vexity) = v
-(v::Concave) = Convex()
-(v::Convex) = Concave()

-(m::Monotonicity) = m
-(m::Nonincreasing) = Nondecreasing()
-(m::Nondecreasing) = Nonincreasing()

-(s::Sign) = s
-(s::Positive) = Negative()
-(s::Negative) = Positive()

+(v::NotDcp, w::NotDcp) = v
+(v::NotDcp, w::Vexity) = v
+(v::Vexity, w::NotDcp) = w

+(v::ConstVexity, w::ConstVexity) = v
+(v::ConstVexity, w::NotDcp) = w
+(v::NotDcp, w::ConstVexity) = v
+(v::ConstVexity, w::Vexity) = w
+(v::Vexity, w::ConstVexity) = v

+(v::Affine, w::Affine) = v
+(v::Affine, w::Convex) = w
+(v::Convex, w::Affine) = v
+(v::Affine, w::Concave) = w
+(v::Concave, w::Affine) = v

+(v::Convex, w::Convex) = v
+(v::Concave, w::Concave) = v
+(v::Concave, w::Convex) = NotDcp()
+(v::Convex, w::Concave) = NotDcp()

+(s::Positive, t::Positive) = s
+(s::Negative, t::Negative) = s
+(s::Positive, t::Negative) = NoSign()
+(s::Negative, t::Positive) = NoSign()
+(s::NoSign, t::NoSign) = s
+(s::NoSign, t::Sign) = s
+(s::Sign, t::NoSign) = t

*(s::NoSign, t::NoSign) = s
*(s::NoSign, t::Sign) = s
*(s::Sign, t::NoSign) = t
*(s::Positive, t::Positive) = s
*(s::Positive, t::Negative) = t
*(s::Negative, t::Positive) = s
*(s::Negative, t::Negative) = Positive()

*(s::Positive, m::Monotonicity) = m
*(s::Negative, m::Monotonicity) = -m
*(s::NoSign, m::Monotonicity) = NoMonotonicity()

*(m::Nondecreasing, v::Vexity) = v
*(m::Nonincreasing, v::Vexity) = -v
*(m::NoMonotonicity, v::Vexity) = v
*(m::NoMonotonicity, v::Convex) = NotDcp()
*(m::NoMonotonicity, v::Concave) = NotDcp()