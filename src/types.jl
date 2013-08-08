type ConditionalProbabilityDistribution
	dname::Symbol      # Distribution name
	parameters::Vector # Parameters as constants or symbols
end

# This is a stochastic node
type GraphicalModelNode
	id::Int
	name::ASCIIString
	field::Symbol
	conditional::ConditionalProbabilityDistribution
	observed::Bool
end

# TODO: Remove vars
type GraphicalModel
	vars::Vector{ASCIIString}
	nodes::Dict{Any, GraphicalModelNode}
	edges::Vector{Any}
end

function GraphicalModel()
	GraphicalModel(Array(ASCIIString, 0),
	               Dict{Any, GraphicalModelNode}(),
	               Array(Any, 0))
end
