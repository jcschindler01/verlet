
zzero(N) = zeros((N,2))
zrand(N) = rand(Float64, (N,2))
vrand(N) = 2. .* rand(Float64, (N,2)) .- 1

function random(N)
	xy  = zrand(N)
	vxy = vrand(N)
	return xy, vxy
end

function corner(N; l=.05)
	xy  = l .* zrand(N)
	vxy = vrand(N)
	return xy, vxy
end

function chain(N)
	##
	lam = range(0,1,N)
	##
	x = .5 .* lam
	y = x .^ 2
	vx = exp.(3 .* x)
	vy = exp.(3 .* y)
	##
	xy  = hcat(x,y)
	vxy = hcat(vx,vy)
	##
	return xy, vxy
end

function stillcircle(N; R=.1)
	s   = range(0,1,N+1)[1:end-1]
	xy  = hcat(0.5 .+ R*cos.(2*pi*s),0.5 .+ R*sin.(2*pi*s))
	vxy = -.01 .* (xy .- .5)
	return xy, vxy
end


