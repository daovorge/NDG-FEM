classdef swe1d < ndg_lib.phys.phys1d
    %SWE1D Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        Nfield = 2  % 物理量场个数
        gra = 9.81
    end
    properties(Abstract, Constant)
        hmin
    end
    
    properties(Abstract)
        M   % TVB 限制器系数
    end

    properties(SetAccess=protected)
        bot     % 底坡高程
        cfl     % CFL 数
        ftime   % 计算终止时间
        dt      % 计算时间步长
        wetflag % 湿单元逻辑数组
        slopelimiter % 斜率限制器
    end

    %% 虚函数
    methods(Abstract)
        init(obj)
    end
    
    %% 私有函数
    methods(Access=protected)
        [ E ] = flux_term( obj, f_Q ) % 计算体积积分通量项 F
        [ dflux ] = surf_term( obj, f_Q )
        [ rhs ] = rhs_term(obj, f_Q ) % 计算右端项
        [ S ] = topo_sour_term( obj, f_Q ) % 底坡源项 
        [ f_Q ] = positive_preserve( obj, f_Q )
        
        function wetdry_detector(obj, f_Q)
            %hm = obj.mesh.cell_mean(f_Q(:,:,1)); % 计算单元平均水深
            obj.wetflag = all(f_Q(:,:,1) > obj.hmin);
            %obj.wetflag = all( f_Q(:,:,1) > obj.hmin );
            % 设置平均水深小于阀值的单元类型为干单元
            obj.mesh.EToR( ~obj.wetflag ) = ndg_lib.mesh_type.Dry;
            obj.mesh.EToR( obj.wetflag ) = ndg_lib.mesh_type.Normal;
        end
        
        function dt = time_interval( obj )
            h = obj.f_Q(:,:,1);
            q = obj.f_Q(:,:,2);
            u = (q./h) + sqrt(obj.gra*h);
            s = bsxfun(@times, obj.mesh.vol/obj.mesh.cell.N, 1./u);
            dt = obj.cfl*min( min( s(:, obj.wetflag) ) );
        end
    end

    %% 公共函数
    methods
        [ dflux ] = hll_surf_term( obj, f_Q ) % 计算边界积分通量差值 (Fn - Fn*)
        [ dflux ] = roe_surf_term( obj, f_Q )
        
        function obj = swe1d(mesh)
            obj = obj@ndg_lib.phys.phys1d(mesh);
            obj.slopelimiter = ndg_utility.limiter.TVB(mesh);
        end
    end

end
