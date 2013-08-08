# TODO: Have this both parse_stochastic and parse_deterministic
function parse_conditional!(ex::Expr, model::GraphicalModel)
	if !isstochastic(ex)
		error("Input is not a conditional")
	end

	varname, fieldname = makevarname(ex.args[2])
	distspec = ex.args[3]

	distname, params = distspec.args[1], distspec.args[2:end]

	# TODO: Remove this
	push!(model.vars, varname)

	# TODO: Revisit ordering of dependencies
	for param in params
		# This should be anything that's not constant
		if isa(param, Symbol) || isa(param, Expr)
			paramname, fieldname = makevarname(param)
			push!(model.edges, [paramname, varname])
		end
	end

	# Stuff we'll want:
	# Length
	# Size
	model.nodes[varname] =
	  GraphicalModelNode(0,
		                 varname,
		                 fieldname,
		                 ConditionalProbabilityDistribution(distname, params),
		                 false)

	return
end

function expandloop(ex::Expr)
	if !isforloop(ex)
		error("Invalid for loop specified")
	end

	loopcontrol = forloopcontrol(ex)
	lower, upper = forloopbounds(ex)

	loopbody = forloopbody(ex)
	loopvar = forloopvar(ex)

	res = Array(Any, 0)

	for loopline in loopbody
		if iscounterline(loopline)
			continue
		end
		if isforloop(loopline)
			for line in expandloop(loopline)
				for constant in lower:upper
					push!(res, substitute(line, loopvar, constant))
				end
			end
		end
		if isassignment(loopline)
			for constant in lower:upper
				push!(res, substitute(loopline, loopvar, constant))
			end
		end
	end

	return res
end

function parse_forloop!(ex::Expr, model::GraphicalModel)
	if !isforloop(ex)
		error("Invalid for loop specified")
	end

	for line in expandloop(ex)
		if isstochastic(line)
			parse_conditional!(line, model)
		end
	end

	return
end

function parse_model(ex::Expr)
	if !isblock(ex)
		error("Invalid model specification")
	end

	model = GraphicalModel()

	for line in blockbody(ex)
		# Only process function calls and for loops
		if isassignment(line)
			parse_conditional!(line, model)
		elseif isforloop(line)
			parse_forloop!(line, model)
		else
			continue
			# error("Invalid expression encountered")
		end
	end

	return model
end
