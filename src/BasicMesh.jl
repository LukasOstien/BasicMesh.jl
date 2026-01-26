module BasicMesh
using Plots
using MeshGrid
using StatsBase

include("helperFunctions.jl")
include("meshGeneration.jl")
include("meshRefinement.jl")

export findBoundary, uniqueElems, enforceGeometry, enforceCircleAll, displayMesh
export hexagon, octagon, squaremesh, circlemesh
export uniformrefine, uniformrefineCircle
end
