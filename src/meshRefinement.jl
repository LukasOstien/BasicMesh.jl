
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

function uniformrefineCircle(node,elem) 
    node2,elem2,HB = uniformrefine(node,elem);
    node2 = enforceGeometry(node2,elem2);
    return node2,elem2,HB
end
