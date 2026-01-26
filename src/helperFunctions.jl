

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

function uniqueElems(A)
    rows = eachrow(A)
    
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

function enforceGeometry(node,elem)
    R = node[2,1];
    bdNode,~ = findBoundary(elem);
    r = sqrt.(node[bdNode,1].^2+node[bdNode,2].^2);
    node[bdNode,1]=R*node[bdNode,1]./r;
    node[bdNode,2]=R*node[bdNode,2]./r;
    return node
end

function enforceCircleAll(node)
    radius = node[2, 1];
    nodesy0 = node[node[:, 2] .== 0.0, :];
    refinement = (size(nodesy0,1)-1)/2; # This will provide the number of intervals between 0 and radius
    h = 1/refinement;
    tol = 0.4*h;
    r = sqrt.(node[:,1].^2+node[:,2].^2);
    for i =1:refinement 
        target_radius = radius*i*h;
        ring_status = zeros(size(node,1),1);
        ring_status = abs.(r.-target_radius) .< tol;
        node[ring_status,1] .= target_radius.*node[ring_status,1]./r[ring_status];
        node[ring_status,2] .= target_radius.*node[ring_status,2]./r[ring_status];
    end
        return node
end

function displayMesh(node,elem)
    p = plot(size=(400, 300), aspect_ratio=:equal, legend=false)
    
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
