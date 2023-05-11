



function random(N)
	xy  = rand(Float64, (N,2))
	vxy = rand(Float64, (N,2)) .- .5
	return xy, vxy
end


function corner(N; l=.05)
	xy  = l .* rand(Float64, (N,2))
	vxy = rand(Float64, (N,2))
	return xy, vxy
end


