
# Usage: Run as script

include("./quickprint.jl")

function help()
	helpstring = 
	"""

	Usage: julia init [file] [-parameters]

	Parameters:
	  -dT     [propagation time]
	  -dt     [output timestep]
	  -dtt    [internal timestep]
	  -nsteps [total output timesteps] (nsteps,dT overrides dt)
  	  -div    [internal timesteps per dt] (div,dt overrides dtt)


	Default: julia verlet.jl data.txt -dT 1 -dt 1e-1 -div 1


	"""
	print(helpstring)
	return helpstring
end

function corner(N; l=0.1)
	k  = 1:N
	x  = .1 .* rand(Float64, N)
	y  = .1 .* rand(Float64, N)
	vx = 1 .+ 0 .* .1 .* rand(Float64, N)
	vy = 1 .+ 0 .* .5 .* rand(Float64, N)
	vrms = sqrt(sum(vx.^2 + vy.^2)/N)
	vx /= vrms
	vy /= vrms
	return k, x, y, vx, vy
end

function normalize_ics(xy,vxy)
	vrms = sqrt(sum(vxy))
end

function headstring(io,N)
	## print
	for dat in ("NOTES", "N", "dT", "dt", "dtt", "t")
		print(io, qp(dat))
	end
	for k in 1:N
		for dat in ("k", "x", "y", "vx", "vy")
			print(io, qp(dat))
		end
	end
	print(io,"\n")
end

function datastring(io, N, k, x, y, vx, vy)
	for dat in ("init", N, 0.0, 0.0, 0.0, 0.0)
		print(io, qp(dat))
	end
	for k in 1:N
		for dat in (k, x[k], y[k], vx[k], vy[k])
			print(io, qp(dat))
		end
	end
	print(io,"\n")
end

function main(;fname="data.txt", N=3, ic=corner)
	## go
	open(fname, "w") do io
		headstring(io, N)
		datastring(io, N, ic(N)...)
	end
end

############ run main #############
## defaults if no input
NX = 3
## check for input
args = ARGS
for opt in 1:length(args)
	if args[opt]=="-N"
		global NX = parse(Int, args[opt+1])
	end
end
## run
main(;N=1*NX)
###################################

