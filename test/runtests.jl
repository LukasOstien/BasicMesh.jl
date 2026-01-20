using BasicMesh
using Test
using Plots
@testset "BasicMesh.jl" begin
    a,b = squaremesh([0,1,0,1],0.25);
    c,d = circlemesh(0,0,1,0.25);
    e,f,g = uniformrefine(a,b);
    h,i,j = uniformrefineCircle(c,d,1);
    @testset "generating shapes" begin
        @test size(a) == (25, 2);
        @test size(b) == (32, 3);
        @test size(c) == (61, 2);
        @test size(d) == (96, 3);
    end
    @testset "refining shapes" begin
        @test size(e) == (81, 2)
        @test size(f) == (128, 3)
        @test size(g) == (56, 3)
        @test size(h) == (217, 2)
        @test size(i) == (384, 3)
        @test size(j) == (156, 3)
    end
    @testset "displaying mesh" begin
        k,l = squaremesh([0,1,0,1],0.25)
        @test_nowarn displayMesh(a,b)
        p = displayMesh(a,b)
        @test p isa Plots.Plot
    end
end
