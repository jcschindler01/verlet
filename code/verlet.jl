
# Usage: julia verlet [file] [-parameters]

include("./quickprint.jl")
include("./physics.jl")


function help()
	helpstring = 
	"""

	Usage: julia verlet [file] [-parameters]

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

struct Params
	file::String         # data file
	dT::Real             # propagation time
	dt::Real             # output timestep
	dtt::Real            # internal timestep
	nsteps::Integer	     # total output timesteps dT/dt
	div::Integer         # internal timesteps per output dt/dtt
	NSTEPS::Integer      # total internal timesteps dT/dtt
end

function Params(;file="data.txt", dT=1.0, dt=1e-1, dtt=1e-1, div=nothing, nsteps=nothing)
	# Uses default values unless given in args. dt = dT/nsteps. dtt=dt/div.
	if nsteps != nothing
		dt = dT/nsteps
	end
	if div != nothing
		dtt = dt/div
	end
	nsteps = integify(dT/dt)
	div = integify(dt/dtt)
	NSTEPS = integify(dT/dtt)
	return Params(file, dT, dt, dtt, nsteps, div, NSTEPS)
end

function integify(x; eps=1e-9)
	if abs(x - round(x))< eps
		return Integer(round(x))
	else
		return nothing
	end	
end

function is_zeroish(x; precis=6)
	return round(x; digits=precis)==0
end

function initialize(args)
	## help
	if "-h" in args
		help()
	end
	## get params dict
	pdict = Dict()
	allowed_keys = ("-dT", "-dt", "-dtt", "-div", "-nsteps")
	# for each allowed key update pdict
	for i in 1:length(args)
		key = args[i]
		if key in allowed_keys
			key = Symbol(key[2:end])
			pdict[key] = parse(Float64, args[i+1])
		end
	end
	## return
	return Params(; pdict...)
end

function readdata(datafile)
	## format is ("note", "N", "dT", "dt", "dtt", "t") + N * ("k", "x", "y", "vx", "vy")
	## read
	datastrings = []
	open(datafile, "r") do io
		datastrings = [strip(s) for s in split(chomp(last(readlines(io))), ",", keepempty=true)]
	end
	## process
	note = datastrings[1]
	N = Integer(length(datastrings[7:end-1])/5)
	dT, dt, dtt, t = (parse(Float64, s) for s in datastrings[3:6])
	x, y, vx, vy = zeros(Float64, N), zeros(Float64, N), zeros(Float64, N), zeros(Float64, N)
	for k in 1:N
		 x[k] = parse(Float64, datastrings[2+5k+1])
		 y[k] = parse(Float64, datastrings[2+5k+2])
		vx[k] = parse(Float64, datastrings[2+5k+3])
		vy[k] = parse(Float64, datastrings[2+5k+4])
	end
	## data
	data = note, N, dT, dt, dtt, t, x, y, vx, vy
	## return
	return data
end

function timestep(dt, t, x, y, vx, vy)
	## velocity verlet method
	# a(t)
	ax0, ay0 = a(x,y)
	# xy(t+dt)
	x  =  x .+ (vx .* dt) .+ (0.5 .* ax0 .* dt^2)
	y  =  y .+ (vy .* dt) .+ (0.5 .* ay0 .* dt^2)
	# a(t+dt)
	ax1, ay1 = a(x,y)
	# vxy(t+dt)
	vx = vx .+ 0.5 .* (ax0 + ax1) .* dt
	vy = vy .+ 0.5 .* (ay0 + ay1) .* dt
	# t
	t += dt
	## return
	return  t, x, y, vx, vy
end

function simulate(params, initial_data)
	## unpack initial data
	note0, N0, dT0, dt0, dtt0, t0, x0, y0, vx0, vy0 = initial_data
	N, dT, dt, dtt = N0, params.dT, params.dt, params.dtt
	## go
	T = 0
	nstep = 1
	note = "sim"
	t, x, y, vx, vy = t0, x0, y0, vx0, vy0
	open(params.file, "a") do io
		while T < dT
			T += dtt
			t, x, y, vx, vy = timestep(dtt, t, x, y, vx, vy)
			if is_zeroish(T-nstep*dt)
				println(nstep)
				nstep +=1
				## print
				for dat in (note, N, dT, dt, dtt, t)
					print(io, qp(dat))
				end
				for k in 1:N
					for dat in (k, x[k], y[k], vx[k], vy[k])
						print(io, qp(dat))
					end
				end
				print(io, "\n")
				note = "..."
				## end print
			end
		end
	end
end

####### main ########
function main(args)
	## process input and get params
	params = initialize(args)
	## read data from file
	initial_data = readdata(params.file)
	## do simulation
	@time simulate(params, initial_data)
	## return
	return nothing
end
#####################

############ run main #############
## defaults if no input
args = ARGS
if length(args)==0
	args = split("data.txt -dT 5 -nsteps 25 -div 1000")
end
## run
main(args)
###################################

