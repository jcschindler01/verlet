



function a(x,y; wall=true, interact=false)
	## init
	ax, ay = zeros(length(x)), zeros(length(x))
	## wall
	if wall==true
		ax .+= -(2*(x .- .5)) .^ 17
		ay .+= -(2*(y .- .5)) .^ 17
	end
	## interact
	if interact==true
		ax .+= -(x .- x[1])
		ay .+= -(y .- y[1])
	end
	## return
	return ax, ay
end


