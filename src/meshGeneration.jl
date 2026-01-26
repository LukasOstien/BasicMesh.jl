
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

function octagon(x,y,radius)
    # create an octagon given the center coordinate
    x = float(x); y = float(y);
    node = zeros(9,2); 
    elem = zeros(Int,8,3);
    node[1,:] = [0,0];
    node[2,:] = [1,0];
    node[3,:] = [sqrt(2)/2,sqrt(2)/2];
    node[4,:] = [0,1];
    node[5,:] = [-sqrt(2)/2,sqrt(2)/2];
    node[6,:] = [-1,0];
    node[7,:] = [-sqrt(2)/2,-sqrt(2)/2];
    node[8,:] = [0,-1];
    node[9,:] = [sqrt(2)/2,-sqrt(2)/2];
    node[:,1] .+= x;
    node[:,2] .+= y;
    node[2:9,:] *= radius;
    elem[1,:] = [1,2,3];
    elem[2,:] = [1,3,4];
    elem[3,:] = [1,4,5];
    elem[4,:] = [1,5,6];
    elem[5,:] = [1,6,7];
    elem[6,:] = [1,7,8];
    elem[7,:] = [1,8,9];
    elem[8,:] = [1,9,2];
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

function circlemesh(xc, yc, radius, h, t)

    # Generate a polygon, user must define t to be 1 or 2
    if t == 1
        node,elem = hexagon(xc,yc,radius);
    elseif t == 2
        node,elem = octagon(xc,yc,radius);
    end

    # refine the mesh until it reaches the 
    # desired subinterval length

    for i = 1:ceil(1/(2*h))
        node,elem,~ = uniformrefine(node,elem);
        node = enforceGeometry(node,elem);
    end
    return node, elem
end
