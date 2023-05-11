#! /bin/sh

# usage: go.sh -N 10 -T dT -n nsteps -d div 

dT=2
nsteps=50
div=100
N=50
ic="random"

while getopts T:n:d:N:i: opt; do
    case $opt in
        T ) dT=${OPTARG};;
        n ) nsteps=${OPTARG};;
        d ) div=${OPTARG};;
        N ) N=${OPTARG};;
        i ) ic=${OPTARG};;
    esac
done

echo " "
echo "dT = $dT"
echo "nsteps = $nsteps"
echo "div = $div"
echo "N = $N"
echo "ic = $ic"

echo " "
echo "init"
julia code/init.jl -N $N -ic $ic
echo "sleep 1s"
sleep 1s
echo "verlet"
julia code/verlet.jl -dT $dT -nsteps $nsteps -div $div
echo "animate"
python3 code/animate.py
echo "view"
viewnior out.gif

