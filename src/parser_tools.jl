# NB: Add a resolve() function
# That it looks in symbol table and decides how to interpret value

#
# Classify the form of an expression
#

isblock(ex::Expr) = ex.head == :block

iscall(ex::Expr) = ex.head == :call

isforloop(ex::Expr) = ex.head == :for

isref(ex::Expr) = ex.head == :ref

iscounterline(ex::Expr) = ex.head == :line

isdeterministic(ex::Expr) = ex.head == :(=)

isstochastic(ex::Expr) = iscall(ex) && ex.args[1] == :(~)

isassignment(ex::Expr) = isdeterministic(ex) || isstochastic(ex)

#
# Build an expression with the proper form
#

buildstochastic(a, b) = Expr(:call, :(~), a, b)

buildref(a, b...) = Expr(:ref, a, b...)

buildcall(a...) = Expr(:call, a...)

#
# Extract information about a for loop
#

function forloopcontrol(ex::Expr)
	if !isforloop(ex)
		error("Input is not a for-loop")
	end

	return ex.args[1]
end

function forloopbody(ex::Expr)
	if !isforloop(ex)
		error("Input is not a for-loop")
	end

	return ex.args[2].args
end

function forloopvar(ex::Expr)
	if !isforloop(ex)
		error("Input is not a for-loop")
	end

	return forloopcontrol(ex).args[1]
end

function forloopbounds(ex::Expr)
	if !isforloop(ex)
		error("Input is not a for-loop")
	end

	return forloopcontrol(ex).args[2].args[1],
	       forloopcontrol(ex).args[2].args[2]
end

#
# Extract the body of a block
#

function blockbody(ex::Expr)
	if !isblock(ex)
		error("Input is not a block")
	end

	return ex.args
end

#
# Associate a variable with a unique name and its enclosing field
#

makevarname(s::Symbol) = string(s), s

function makevarname(ex::Expr)
	# Make the string for :(x[1]) be x[1]
	# Make the string for :(x[g[i]]) be x[2] if g[i] = 2
	if isref(ex)
		string(ex), ex.args[1]
	else
		error("Invalid varname: $ex")
	end
end

#
# Substitute a specific symbol with a constant
#

function substitute(x::Number, loopvar::Symbol, constant::Integer)
	return x
end

function substitute(s::Symbol, loopvar::Symbol, constant::Integer)
	if s == loopvar
		return constant
	else
		return s
	end
end

function substitute(s::Colon, loopvar::Symbol, constant::Integer)
	return Colon()
end

function substitute(ex::Expr, loopvar::Symbol, constant::Integer)
	if isref(ex)
		return buildref(ex.args[1],
			            map(index -> substitute(index, loopvar, constant),
			                ex.args[2:end])...)
	elseif isstochastic(ex)
		return buildstochastic(substitute(ex.args[2], loopvar, constant),
					           substitute(ex.args[3], loopvar, constant))
	elseif iscall(ex)
		return buildcall(map(index -> substitute(index, loopvar, constant),
			                 ex.args[1:end])...)
	else
		error("Not able to process non-stochastic lines")
	end
end
