function [ FToN1, FToN2, nx, ny, nz, Js ] = assembleNodeProject( obj, mesh )

cell = mesh.cell;
eNfp = obj.eCell.Np;
FToN1 = zeros( eNfp, obj.Ne );
FToN2 = zeros( eNfp, obj.Ne );
nx = zeros( eNfp, obj.Ne );
ny = zeros( eNfp, obj.Ne );
nz = zeros( eNfp, obj.Ne );
Js = zeros( eNfp, obj.Ne );

for n = 1:obj.Ne
    k1 = obj.FToE(1, n);
    k2 = obj.FToE(2, n);
    f1 = obj.FToF(1, n);
    f2 = obj.FToF(2, n);
    vert1 = mesh.EToV( cell.FToV(:, f1), k1);
    vert2 = mesh.EToV( cell.FToV(:, f2), k2);
    
    % set local node index
    FToN1(:, n) = cell.Fmask(:, f1);
    if vert2(1) == vert1(1)
        FToN2(:, n) = mesh.cell.Fmask(:, f2);
    else
        FToN2(:, n) = flip( mesh.cell.Fmask(:, f2) );
    end
    
    if mesh.cell.type == NdgCellType.Tri
        [ nx(:, n), ny(:, n), Js(:, n) ] = TriJacobian2d( mesh, f1, k1, FToN1(:, n) );
    elseif mesh.cell.type == NdgCellType.Quad
        [ nx(:, n), ny(:, n), Js(:, n) ] = QuadJacobian2d( mesh, f1, k1, FToN1(:, n) );
    end
    % set outward normal vector
    % tmp = sum( cell.Nfp(1:f1) );
    % fid = (tmp - cell.Nfp(f1) + 1):tmp;
    % nx(:, n) = mesh.nx(fid, k1);
    % ny(:, n) = mesh.ny(fid, k1);
    % nz(:, n) = mesh.nz(fid, k1);
    % Js(:, n) = mesh.Js(fid, k1);
end

end

function [ nx, ny, Js ] = QuadJacobian2d( mesh, f1, e1, nodeId )
rx = mesh.rx( nodeId, e1 ); ry = mesh.ry( nodeId, e1 );
sx = mesh.sx( nodeId, e1 ); sy = mesh.sy( nodeId, e1 );

if f1 == 1
    nx = - sx;
    ny = - sy;
elseif f1 == 2
    nx = rx;
    ny = ry;
elseif f1 == 3
    nx = sx;
    ny = sy;
elseif f1 == 4
    nx = - rx;
    ny = - ry;
end

Js = sqrt( nx .* nx + ny .* ny );
nx = nx ./ Js;
ny = ny ./ Js;
Js = Js .* mesh.J( nodeId, e1 );

end

function [ nx, ny, Js ] = TriJacobian2d( mesh, f1, e1, nodeId )
rx = mesh.rx( nodeId, e1 ); ry = mesh.ry( nodeId, e1 );
sx = mesh.sx( nodeId, e1 ); sy = mesh.sy( nodeId, e1 );

if f1 == 1
    nx = - sx;
    ny = - sy;
elseif f1 == 2
    nx = rx + sx;
    ny = ry + sy;
elseif f1 == 3
    nx = - rx;
    ny = - ry;
end

Js = sqrt( nx .* nx + ny .* ny );
nx = nx ./ Js;
ny = ny ./ Js;
Js = Js .* mesh.J( nodeId, e1 );

end

