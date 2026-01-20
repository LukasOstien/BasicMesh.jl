module BasicMesh
using Plots
using MeshGrid
using StatsBase
# Write your package code here.
export circlemesh, displayMesh, enforceGeometry, findBoundary, hexagon, squaremesh, uniformrefine, uniformrefineCircle 
    function circlemesh(xc, yc, radius, h)

        # Generate a Hexagon, then refine some times
        node,elem = hexagon(xc,yc,radius);

        # refine the mesh until it reaches the 
        # desired subinterval length

        for i = 1:ceil(1/(2*h))
            node,elem,~ = uniformrefine(node,elem);
            node = enforceGeometry(node,elem,radius);
        end
        return node, elem
    end

    function displayMesh(node,elem)
        p = plot(size=(800, 600), aspect_ratio=:equal, legend=false)
        
        # Plot triangles
        nelm = size(elem, 1);
        for i in 1:nelm
            tri = node[elem[i,:], :]
            # Close the triangle
            tri_closed = vcat(tri, tri[1:1,:])
            plot!(p, tri_closed[:,1], tri_closed[:,2])
        end
        
        # Plot nodes
        scatter!(p, node[:,1], node[:,2])
        return p
    end

    function enforceGeometry(node,elem,R)
        bdNode,~ = findBoundary(elem);
        r = sqrt.(node[bdNode,1].^2+node[bdNode,2].^2);
        node[bdNode,1]=R*node[bdNode,1]./r;
        node[bdNode,2]=R*node[bdNode,2]./r;
        return node
    end

    function findBoundary(elem)
        # Count edge occurrences
        edge_count = Dict{Tuple{Int,Int},Int}()
        hold = size(elem,1);
        for t in 1:hold
            i, j, k = elem[t, 1], elem[t, 2], elem[t, 3]
            
            # Sort edges to ensure consistent ordering
            edges = [(min(j, k), max(j, k)),
                    (min(k, i), max(k, i)),
                    (min(i, j), max(i, j))]
            
            for e in edges
                edge_count[e] = get(edge_count, e, 0) + 1
            end
        end
        
        # Boundary edges appear only once
        bdEdges = [e for (e, count) in edge_count if count == 1]
        
        # Get unique boundary nodes
        bdNodesSet = Set{Int}()
        for (i, j) in bdEdges
            push!(bdNodesSet, i, j)
        end
        
        return sort(collect(bdNodesSet)),bdEdges
    end

    function hexagon(x,y,radius)
        # create a hexagon given the center coordinate
        node = zeros(7,2);
        elem = zeros(Int,6,3);
        node[1,:] = [x,y];
        node[2,:] = [1.0+x,0.0+y];
        node[3,:] = [0.5+x,sqrt(3)/2+y];
        node[4,:] = [-0.5+x,sqrt(3)/2+y];
        node[5,:] = [-1.0+x,0.0+y];
        node[6,:] = [-0.5+x,-sqrt(3)/2+y];
        node[7,:] = [0.5+x,-sqrt(3)/2+y];
        node[2:7,:] *= radius;
        elem[1,:] = [1,2,3];
        elem[2,:] = [1,3,4];
        elem[3,:] = [1,4,5];
        elem[4,:] = [1,5,6];
        elem[5,:] = [1,6,7];
        elem[6,:] = [1,7,2];
        return node, elem
    end

    function squaremesh(square,h)
        x0 = square[1]; x1 = square[2]; 
        y0 = square[3]; y1 = square[4];
        x,y = meshgrid(x0:h:x1,y0:h:y1);
        node = node = hcat(vec(x), vec(y));
        nx = length(x0:h:x1);
        ny = length(y0:h:y1);
        i = 1:(nx-1);
        j = 1:(ny-1);
        
        # Create linear indices for all lower-left corners
        ll = vec([i + (jj-1)*nx for jj in j, i in i]);
        
        # Create triangles (each square gives 2 triangles)
        elem = vcat(
            # Lower triangles
            hcat(ll, ll.+1, ll.+nx),
            # Upper triangles  
            hcat(ll.+1, ll.+nx.+1, ll.+nx)
        );
        return node,elem
    end

    function uniformrefine(node,elem)
        

        # Construct Data Structure
        edgeshold = vcat(elem[:, [2,3]],elem[:, [3,1]],elem[:, [1,2]]);
        sort!(edgeshold,dims=2);
        totalEdges = UInt32.(edgeshold)
        edge,j = uniqueElems(totalEdges);
        N = size(node,1); NT = size(elem,1); NE = size(edge,1);
        elem2edge = UInt32.(reshape(j,NT,3));

        # Add new nodes: middle points of all edges
        
        HB = zeros(Int, NE, 3);
        node2 = zeros(eltype(node), N + NE, size(node,2));
        node2[1:N, :] .= node;
        node2[N+1:N+NE,:] = (node[edge[:,1],:]+node[edge[:,2],:])/2; 
        HB[:, 1] .= N+1:N+NE;
        HB[:, 2:3] .= edge[:, 1:2];  
        edge2newNode = UInt32.((N+1:N+NE)');
        
        # Refine Triangles into four triangles
        t = 1:NT; t1 = t; t2 = NT .+ t; t3 = 2*NT.+t; t4 = 3*NT .+ t;
        p = zeros(Int, length(t), 6)
        elem2 = zeros(eltype(elem),t4[end],size(elem,2));
        elem2[t,:] .= elem;
        p[t,1:3] = elem[t,1:3];
        p[t,4:6] = edge2newNode[elem2edge[t,1:3]];
        elem2[t4,:] = hcat(p[t,4],p[t,5],p[t,6]);
        elem2[t1,:] = hcat(p[t,1],p[t,6],p[t,5]);
        elem2[t2,:] = hcat(p[t,6],p[t,2],p[t,4]);
        elem2[t3,:] = hcat(p[t,5],p[t,4],p[t,3]);

        return node2,elem2,HB
    end

    function uniqueElems(A)
        rows = eachrow(A)
        
        # Use dictionary for O(1) lookups
        unique_dict = Dict{Vector{eltype(A)}, Int}()
        j = zeros(Int, size(A, 1))
        unique_rows = Vector{Vector{eltype(A)}}()
        
        # Build mapping and collect unique rows
        for (idx, row) in enumerate(rows)
            row_vec = collect(row)
            if !haskey(unique_dict, row_vec)
                unique_dict[row_vec] = length(unique_rows) + 1
                push!(unique_rows, row_vec)
            end
            j[idx] = unique_dict[row_vec]
        end
        
        
        
        # Convert to matrix
        sortA = reduce(vcat, [u' for u in unique_rows])
        
        return sortA,j
    end

    function uniformrefineCircle(node,elem,R)
        node2,elem2,HB, = uniformrefine(node,elem);
        node2 = enforceGeometry(node2,elem2,R);
        return node2,elem2,HB
    end

end
