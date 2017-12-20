classdef PerturbHump2d < SWEPreBlanaced2d & SDBAbstractTest & CSBAbstractTest
    %PERTURBHUMP2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties( Constant )
        gra = 9.81
        hmin = 1e-4
    end
    
    methods
        function obj = PerturbHump2d(N, M, cellType)
            [ mesh ] = makeUniformMesh(N, M, cellType);
            obj = obj@SWEPreBlanaced2d();
            obj.initPhysFromOptions( mesh );
            obj.fext = obj.setInitialField( );
        end
    end
    
    methods(Access=protected)
        function fphys = setInitialField( obj )
            fphys = cell( obj.Nmesh, 1 );
            for m = 1:obj.Nmesh
                mesh = obj.meshUnion(m);
                fphys{m} = zeros( mesh.cell.Np, mesh.K, obj.Nfield );
                
                bot = 0.8*exp( -5*(mesh.x - 0.9).^2 - 50*(mesh.y - 0.5).^2 );
                fphys{m}(:,:,4) = bot;
                fphys{m}(:,:,1) = 1 - bot;
%                 ind = ( mesh.xc >= 0.05 ) & ( mesh.xc <= 0.15 );
%                 fphys{m}(:,ind,1) = fphys{m}(:,ind,1) + 0.01;
            end
        end
        
        function [ option ] = setOption( obj, option )
            ftime = 0.6;
            outputIntervalNum = 50;
            option('startTime') = 0.0;
            option('finalTime') = ftime;
            option('temporalDiscreteType') = NdgTemporalIntervalType.DeltaTime;
            option('obcType') = NdgBCType.None;
            option('outputIntervalType') = NdgIOIntervalType.DeltaTime;
            option('outputTimeInterval') = ftime/outputIntervalNum;
            option('outputNetcdfCaseName') = mfilename;
            option('temporalDiscreteType') = NdgTemporalDiscreteType.RK45;
            option('limiterType') = NdgLimiterType.Vert;
            option('equationType') = NdgDiscreteEquationType.Strong;
            option('integralType') = NdgDiscreteIntegralType.QuadratureFree;
            option('CoriolisType')=CoriolisType.None;
            option('WindType')=WindType.None;
            option('FrictionType')=FrictionType.None;
        end
    end
end

function [ mesh ] = makeUniformMesh(N, M, type)
bctype = [...
    NdgEdgeType.SlipWall, ...
    NdgEdgeType.SlipWall, ...
    NdgEdgeType.ZeroGrad, ...
    NdgEdgeType.ZeroGrad];

xlim = [0, 2]; 
ylim = [0, 1];
if (type == NdgCellType.Tri)
    mesh = makeUniformTriMesh(N, xlim, ylim, M, ceil(M/2), bctype);
elseif(type == NdgCellType.Quad)
    mesh = makeUniformQuadMesh(N, xlim, ylim, M, ceil(M/2), bctype);
else
    msgID = [mfile, ':inputCellTypeError'];
    msgtext = 'The input cell type should be NdgCellType.Tri or NdgCellType.Quad.';
    ME = MException(msgID, msgtext);
    throw(ME);
end
end% func

