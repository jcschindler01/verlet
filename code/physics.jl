

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

function z(xy; L=.9)
	## scaled vector displacement from center of box at x, y = (.5,.5).
	return (xy .- .5)/(.5*L)
end

function Fwall(xy)
	##
	fpoly(z; u=10) = - z .^ (2u-1)
	fexp(z) = - sinh.(z)
	##
	F = fpoly(z(xy); u=10)
	## 
	return F
end




