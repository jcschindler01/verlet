

using LinearAlgebra

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

## mass
const mass = 1

## acceleration from forces
function a(x,y; forces=[Fwall, Finteraction])
	##
	xy = hcat(x,y)
	a = zeros(size(xy))
	##
	for force in forces
		a .+= force(xy) ./ mass
	end
	## ax, ay = a
	return a[:,1], a[:,2]
end


#=
Define forces.
=#


#=
Wall.

Total potential energy is
U = sum_{particles} [Uwall(x_i) + Uwall(y_i)].
=#

## wall
H(xy)  = 0.5*(sign.(xy).+1)
g1(xy) = H.(xy) .* xy
g2(xy) = H.(xy) .* xy.^2

## wall scale
const lwall = 1e-4
const ewall = 1
const Ewall = ewall*lwall

## wall potential
function Uwall(xy; l=lwall)
	## U = E * [H(-z)*(z/l)^2 + H(z-1)*((z-1)/l)^2]
	return Ewall .* ( H(-xy).*(-xy./l).^2 .+ H(xy.-1).*((xy.-1)./l).^2 )
end

## wall force
function Fwall(xy; l=lwall)
	## f = (2E/l) * [H(-z)*(z/l) - H(z-1)*((z-1)/l)]
	return (2*Ewall/l) .* ( H(-xy).*(-xy./l) .- H(xy.-1).*((xy.-1)./l) )
end




#=
Interparticle interaction.

Total potential energy is
U = sum_{ij} (E0/2) * V(r_ij) * (1-delta_ij).
=#


## hard sphere repulsion potential
const ra = 1e-3
const rb = 1e-9
const p0 = 2
const e0 = 1
const E0 = e0*ra
V0(r; ra=ra, rb=rb, p=p0) = (ra./sqrt.(r.^2 .+ rb.^2)).^p
V0prime(r; ra=ra, rb=rb, p=p0) = -(p/ra) .* (ra./sqrt.(r.^2 .+ rb.^2)).^(p+1) .* (r/sqrt.(r.^2 .+ rb.^2))

## total central force
function Finteraction(xy)
	N = length(xy[:,1])
	f = zeros((N,2))
	for i in 1:N
		for j in 1:N
			if i != j
				xyij = xy[j,:] .- xy[i,:]
				rij  = norm(xyij)
				f[i,:] .+= -(E0/2) * V0prime(rij) .* (xyij./rij)
			end
		end
	end
	return f
end






