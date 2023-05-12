

#= 
Proper way to go from x,y to xy and back.
	xy  = hcat(x,y)
	x,y = xy[:,1], xy[:,2]
The joint one has the form
	xy[N,2]
so that
	xy[k,:]
is the vector position of kth particle.
=#

const mass = 1

function a(x,y; forces=[Fwall])
	##
	xy = hcat(x,y)
	a = zeros(size(xy))
	##
	for force in forces
		a .+= force(xy) / mass
	end
	## ax, ay = a
	return a[:,1], a[:,2]
end


## helpers
H(xy) = 0.5*(sign.(xy).+1)   ## heaviside theta
z(xy; L=1) = (xy.-.5)/(.5*L) ## displacement from center
g(xy) = H.(xy).*(exp.(xy).-1) ## piecewise zero exponential
glin(xy) = H.(xy).*xy

## walls
fpoly(z; u=10) = -z.^(2*u-1) ## polynomial wall function
fexp(xy; l=1e-4, w=0) = g(-(xy.-w)/l) .- g((xy.-(1-w))/l)
felastic(xy; l=.1e-6) = glin(-xy/l) .- glin((xy.-1)/l)

function Fwall(xy)
	return felastic(xy; l=1e-6)
end

