
# Usage: julia init.jl -N 50 -i corner

include("./quickprint.jl")
include("./ics.jl")

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

function normalize_ics(xy,vxy)
	##
	N = length(xy[:,1])
	k = 1:N
	vrms = sqrt(sum(vxy .^ 2)/N)
	vxy = vxy / vrms
	##
	x, y = xy[:,1], xy[:,2]
	vx, vy = vxy[:,1], vxy[:,2]
	##
	return k, x, y, vx, vy
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

function main(;fname="data.txt", N=3, ic=random)
	## initial data
	data = normalize_ics(ic(N)...)
	## go
	open(fname, "w") do io
		headstring(io, N)
		datastring(io, N, data...)
	end
end

############ run main #############
## defaults if no input
NX = 3
ic = "corner"
## check for input
args = ARGS
for opt in 1:length(args)
	if args[opt] in ("-N",)
		global NX = parse(Int, args[opt+1])
	end
	if args[opt] in ("-i", "-ic")
		global ic = args[opt+1]
	end
end
## ic string to function
ic = getfield(Main, Symbol(ic))
## run
main(;N=1*NX, ic=ic)
###################################

