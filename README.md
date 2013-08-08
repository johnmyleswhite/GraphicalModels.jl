GraphicalModels.jl
==================

Parse graphical models using a BUGS-like notation and represent the models as Julian data structures:

	using GraphicalModels

	ex = quote
		for i in 1:3
			mu[i] ~ Normal(0, 1)
		end
		for j in 1:3
			sigma[j] ~ Gamma(1, 1)
		end
		for i in 1:3
			for j in 1:2
				x[i, j] ~ Normal(mu[i], sigma[j])
			end
		end
	end

	model = GraphicalModels.parse_model(ex)

	index, inverse_index = GraphicalModels.build_indices(model)
