function build_indices(model::GraphicalModel)
	inverse_index = Dict{Any, Int}()

	N = length(model.vars)

	for i in 1:N
		inverse_index[model.vars[i]] = i
	end

	g = simple_graph(N)

	for edge in model.edges
		add_edge!(g, inverse_index[edge[2]], inverse_index[edge[1]])
	end

	sorted_vars = topological_sort_by_dfs(g)

	index = model.vars[reverse(sorted_vars)]

	for i in 1:N
		inverse_index[index[i]] = i
	end

	return index, inverse_index
end
