#! /bin/sh

# usage: go.sh -T dT -n nsteps -d div -N 10

dT=4
nsteps=20
div=1000
N=10

while getopts T:n:d:N opt; do
    case $opt in
        T ) dT=${OPTARG};;
        n ) nsteps=${OPTARG};;
        d ) div=${OPTARG};;
        N ) N=${OPTARG};;
    esac
done

echo " "
echo "dT = $dT"
echo "nsteps = $nsteps"
echo "div = $div"
echo "N = $N"

echo " "
echo "init"
julia code/init.jl -N $N
echo "verlet"
julia code/verlet.jl -dT $dT -nsteps $nsteps -div $div
echo "animate"
python3 code/animate.py
echo "view"
viewnior out.gif

