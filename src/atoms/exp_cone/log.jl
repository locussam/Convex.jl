#############################################################################
# log.jl
# natural logarithm of an logression
# All expressions and atoms are subtpyes of AbstractExpr.
# Please read expressions.jl first.
#############################################################################

import Base.log
export log
export sign, curvature, monotonicity, evaluate

### Logarithm

type LogAtom <: AbstractExpr
  head::Symbol
  id_hash::Uint64
  children::(AbstractExpr,)
  size::(Int, Int)

  function LogAtom(x::AbstractExpr)
    children = (x,)
    return new(:log, hash(children), children, x.size)
  end
end

function sign(x::LogAtom)
  return NoSign()
end

function monotonicity(x::LogAtom)
  return (Nondecreasing(),)
end

function curvature(x::LogAtom)
  return ConcaveVexity()
end

function evaluate(x::LogAtom)
  return log(evaluate(x.children[1]))
end

log(x::AbstractExpr) = LogAtom(x)

function conic_form!(e::LogAtom, unique_conic_forms::UniqueConicForms)
  if !has_conic_form(unique_conic_forms, e)
    # log(z) \geq x  <=>  (x,ones(),z) \in ExpCone
    z = e.children[1]
    y = Constant(ones(size(z)))
    x = Variable(size(z))
    objective = conic_form!(x, unique_conic_forms)
    conic_form!(ExpConstraint(x, y, z), unique_conic_forms)

    cache_conic_form!(unique_conic_forms, e, objective)
  end
  return get_conic_form(unique_conic_forms, e)
end
