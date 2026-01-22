# BasicMesh
[![Build Status](https://github.com/LukasOstien/BasicMesh.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LukasOstien/BasicMesh.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LukasOstien/BasicMesh.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LukasOstien/BasicMesh.jl) <br>
This package aims to generate uniform meshes for user defined shapes. At this moment in time the package can develop meshes for rectangles and circles, and can uniformly refine down meshes, shown below: <br>
To add this package, use the following command:
```julia
using Pkg; Pkg.add("BasicMesh")
```
To generate a mesh, use wither the squaremesh() or circlemesh() functions as follows:
```julia
## For a rectangle, describe the box by supplying xmin, xmax, ymin, ymax, and the subinterval length:
box = [0,1,0,1] # square in [0,1]^2
node,elems = squaremesh(box,0.25);

## For a circle, supply the center coordinate, the radius, and the subinterval length:
R = 1;
cnode,celems = circlemesh(0,0,R,0.25) # Circle at (0,0) with radius of 1 with subinterval length of ~0.25
```
If you are interested in displaying the mesh:
```julia
s = displayMesh(node,elems);
c = displayMesh(cnode,celems);
display(s)
display(c)
```
The results should look like this: <br>
![](https://github.com/LukasOstien/BasicMesh.jl/blob/main/images/plot_1.png) ![](https://github.com/LukasOstien/BasicMesh.jl/blob/main/images/plot_3.png) <br>
To refine meshes, call the appropirate refining function, and display to see the results:
```julia
fnode,felems,HBs = uniformrefine(node,elems);
# For consistency, use the same R you called in the circlemesh() subroutine.
fcnode,fcelems,HBc = uniformrefineCircle(cnode,celems,R); 
fs = displayMesh(fnode,felems);
fc = displayMesh(fcnode,fcelems);
dislpay(fs)
display(fc)
``` 
![](https://github.com/LukasOstien/BasicMesh.jl/blob/main/images/plot_2.png) ![](https://github.com/LukasOstien/BasicMesh.jl/blob/main/images/plot_4.png) <br>
The refining functions supply a matrix that maps fine level indices HB[:,1] and relates them to corresponding coarse level indices HB[:,2:3], which is quite useful in multigrid settings. <br>

This project is inspired by the much more sophisticated library for MATLAB, [iFem](https://github.com/lyc102/ifem), written by Long Chen, a professor I had the privilege of having when taking a PDEs class at UC Irvine. <br>
