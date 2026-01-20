using BasicMesh
using Test

@testset "BasicMesh.jl" begin
    a,b = squaremesh([0,1,0,1],0.25);
    @test size(a) == (25, 2);
    @test size(b) == (32, 3);
end
