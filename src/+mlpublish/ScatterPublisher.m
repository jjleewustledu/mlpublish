
classdef ScatterPublisher % < mlpublish.AbstractPublisher
    %% SCATTERPUBLISHER uses factory designs patterns to create scatter plots on screen
    %                   and optionally writes them to disk.
    %
    %  Created by John Lee on 2008-06-28.
    %  Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email = "bugs.cvl.neuroimage.wustl.edu@gmail.com"/>.

    properties
        mrimgs             = {};
    end
    
    properties (Access = 'private')
        xvecs              = {};
        yvecs              = {};
        publishProps       = {};
        handlesScatter     = [];
        handlesBlandAltman = [];
    end
    
    methods
        
        function             obj = ScatterPublisher(props)

            %% SCATTERPUBLISHER 
            %  Usage:  obj = mlfourd.ScatterPublisher(props)
            %                                         ^ ScatterProperties object 
            %                                           contains specifiers for display & printing
            %  To do:  set access to protected to encourage use of factory design patterns
            %obj = obj@mlpublish.AbstractPublisher(varargin);
            switch (nargin)
                case 0    % required by Matlab
%                    obj.publishProps = mlpublish.PublishProperties; % default
                 case 1
%                     assert(isa(props, 'mlpublish.PublishProperties'), ...
%                           'mlpublish.TypeErr:unrecognizedType', ...
%                          ['type of props was not recognized: ' class(props)]);
%                    assert(props.checkSelf);
%                    obj.publishProps = props;
                otherwise
                    error('mlpublish:InputParamsErr:NumberOfParamsUnsupported', ...
                         ['mlpublish.ScatterPublisher.ctor does not support ' ...
                           num2str(nargin) ' passed params.']);
            end
        end % ScatterPublisher (ctor)
                        
        
        function  handlesRegress = plotScatter(obj,label)
            
            %% PLOTSCATTER
            %  Usage:  handlesRegress = plotScatter(obj,label)
            %                                           ^ for diary
            import mlpublish.*;
            % use local props, xv, yv in anticipation of conversion to handle class
            props             = obj.publishProps; % must be safe for copy by value & by ref
            props.scatter     = true; 
            props.BlandAltman = false;
            if (~isempty(obj.publishProps.filestemEps))
                props.filestemEps = [obj.publishProps.filestemEps '_plotScatter_' label];
            end
             xv         = obj.xvecs;
             yv         = obj.yvecs;
            [xv, props] = ScatterPublisher.rescaleVectors(xv, props);
            [yv, props] = ScatterPublisher.rescaleVectors(yv, props, obj.mrimgs);
            
            % plot main figure components
            figure('Units', 'pixels', 'Position', ...
                   [props.offsetFromEdge props.offsetFromEdge ...
                    props.pixelSize      props.pixelSize]);
            hold on;  
            sumrr = 0;
            for r = 1:length(props.regressionRequests)
                sumrr = sumrr + props.regressionRequests{r};
            end
            regressed      = cell(1, sumrr);
            scattered      = cell(1, length(xv));
            handlesRegress = zeros(  sumrr, 1);
            for i = 1:length(xv)
                scattered{i} =    plot(xv{i}, yv{i}, props.markers{i});
                %%scattered{i} =    cftool(xv{i}, yv{i});
                set(scattered{i}, 'MarkerSize',            props.markerArea{i}, ...
                                  'MarkerEdgeColor',       props.markerColors{i});
            end
            i1 = 1;
            for i = 1:length(xv)
                incr  =    (max(xv{i}) - min(min(xv{i}, yv{i})))/length(xv{i});
                if (~isempty(props.anXLim))
                    xspan = (props.anXLim(1)):incr:(props.anXLim(2));
                else
                    xspan = min(xv{i}):incr:max(xv{i});
                end
                if (props.regressionRequests{i})
                    try
                        % options           = fitoptions('Normalize', 'on');
                        [cfun gof fitout] = fit(xv{i}, yv{i}, props.libmodel);
                        
                        
                    catch ME
                        disp(ME.message);
                        disp('calling fit with no options');
                        [cfun gof fitout] = fit(xv{i}, yv{i}, props.libmodel);
=======
classdef ScatterPublisher
    
    %% SCATTERPUBLISHER uses factory designs patterns to create scatter plots on screen
    %                   and optionally writes them to disk.   Tests should only write to disk.
    %
    %  Instantiation:  self = mlpublish.ScatterPublisher(props)
    %
    %                  props:  struct or class of specifiers for display & printing
    %
    %  Created by John Lee on 2008-06-28.
    %  Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
    %    
    properties
        mrimgs             = {};
    end
    properties (Access = 'private')
        xvecs              = {};
        yvecs              = {};
        props              = {};
        handlesScatter     = [];
        handlesBlandAltman = [];
    end
    
    methods (Static)
        
        %% Static factory MAKESCATTERFROMFILENAMES plots data from their filesystem locations
        %  Usage:   obj = mlpublish.ScatterPublisher. ...
        %                 makeScatterFromPetFromFilenames(pnum, fqfnmr, fqfnfg, props)
        function    obj = makeScatterFromPetFromFilenames(pnum, fqfnmr, fqfnfg, props)
            
            assert(nargin == 4);
            fqfnpet = mlpet.PETBuilder.PETfactory(pnum, props.xMetric).fileprefix;
            assert(ischar(fqfnpet));
            assert(ischar(fqfnmr));
            assert(ischar(fqfnfg));
            obj   = mlpublish.ScatterPublisher.makeScatterFromFilenames( ...
                fgfnpet, fqfnmr, fqfnfg, props)
        end % static factory makeScatterFromPetFromFilenames
        
        %% Static  MAKESCATTERFROMPETFROMNII generates PET NIfTI, collects MR
        %                                    and mask NIfTI and plots data
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromPetFromNii(pnum, mrnii, fgnii, props)
        function   obj = makeScatterFromPetFromNii(pnum, mrnii, fgnii, props)
            
            assert(nargin == 4);
            petnii = mlpet.PETBuilder.PETfactory(pnum, props.xMetric);
            obj = mlpublish.ScatterPublisher.makeScatterFromNii( ...
                petnii, mrnii, fgnii, props);
        end % static factory makeScatterFromPetFromNii
        
        %% Static factory MAKESCATTERFROMPETFROMNIIS generates PET NIfTIs, collects cell-arryays of
        %                                     MR and mask NIfTIs and plots segreated data
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromPetFromNiis(pnum, mrniis, fgniis, props)
        function   obj = makeScatterFromPetFromNiis(pnum, mrniis, fgniis, props)
            
            import mlfourd.*;
            import mlpublish.*;
            assert(nargin == 4);
            petniis = cell(1, length(mrniis));
            petnii  = mlpet.PETBuilder.PETfactory(pnum, props.xMetric);
            for s = 1:length(mrniis)
                petniis{s} = petnii;
            end
            obj     = ScatterPublisher.makeScatterFromNiis(petniis, mrniis, fgniis, props)
        end % static factory makeScatterFromPetFromNiis
        
        %% Static factory MAKESCATTERFROMFILENAMES makes aplot from filenames
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromFilenames(xfqfn, yfqfn, fqfnfg, props)
        %          xfqfn, yfqfn:  fully-qual. filenames for x & y data
        %          props:         plot properties              (option)
        %          fqfnfg:        fully-qual. filename of mask (option)
        %          obj:           ScatterPublisher instance
        function   obj = makeScatterFromFilenames(xfqfn, yfqfn, fqfnfg, props)
            
            import mlpublish.*;
            import mlfourd.*;
            switch (nargin)
                case 2
                    props = PublishProperties; % default values
                    xnii  = load_nii(xfqfn);
                    fgnii = NiiBrowser.make_nii1(...
                        ones(size(xnii.img)), [1 1 1], [0 0 0], 16, ' -> makeScatterFromFilenames');
                case 3
                    xnii  = load_nii(xfqfn);
                    fgnii = NiiBrowser.make_nii1(...
                        ones(size(xnii.img)), [1 1 1], [0 0 0], 16, ' -> makeScatterFromFilenames');
                case 4
                    fgnii = load_nii(fqfnfg)
                otherwise
                    error('mlpublish:InputParamsErr', ...
                        ['nargin -> ' num2str(nargin) ' is unsupported']);
            end
            ynii = load_nii(yfqfn);
            obj  = ScatterPublisher.makeScatterFromNii(xnii, ynii, fgnii, props);
        end % static factory makeScatterFromFilenames
        
        %% Static factory MAKESCATTERFROMNII makes a plot from NIfTI
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromNii(xnii,   ynii,   fgnii,  props)
        function   obj = makeScatterFromNii(xnii,   ynii,   fgnii,  props)
            obj = mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                {xnii}, {ynii}, {fgnii}, props);
        end % static factory makeScatterFromNii
        
        %% Static factory MAKESCATTERFROMNIIS makes a plot from cell-arrays of matched data for publication.
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromNiis(xniis, yniis, fgniis, props)
        %  Calls:  defaultPrintProps
        %          isNIfTI
        %          makeFg_noDataZeros
        %          NiiBrowser.ctor
        %          NiiBrowser.sampleVoxels
        %          makeScatterFromCells
        function   obj = makeScatterFromNiis(xniis, yniis, fgniis, props)
            
            import mlfourd.*;
            import mlpublish.*;
            switch (nargin)
                case 2
                    for s = 1:length(xniis);
                        fgniis{s} = NiiBrowser.make_ones_nii(xniis{1});
>>>>>>> .merge-right.r251
                    end
<<<<<<< .working
                    [spearrho pval]            = corr([xv{i} yv{i}], 'type', 'Spearman'); % 'rows', 'complete'
                    regressed{i1}.spearrho     = spearrho;
                    regressed{i1}.pval    = pval;
                    regressed{i1}.cfun    = cfun;
                    regressed{i1}.gof     = gof;
                    regressed{i1}.fitout  = fitout;
                    regressed{i1}.pi      = predint(cfun, xspan, ...
                                                    props.confidenceInterval, 'functional', 'on');
                    switch (props.libmodel)
                        case 'poly1'
                            regressed{i1}.fittedy =                                       cfun.p1*xspan + cfun.p2;
                        case 'poly2'
                            regressed{i1}.fittedy =                    cfun.p1*xspan.^2 + cfun.p2*xspan + cfun.p3;
                        case 'poly3'
                            regressed{i1}.fittedy = cfun.p1*xspan.^3 + cfun.p2*xspan.^2 + cfun.p3*xspan + cfun.p4;
                        otherwise
                            error('mlpublish:NotImplementedErr', ...
                                 ['ScatterPublisher.plotScatter could not recognize ' props.libmodel]);
=======
                    props = PublishProperties;
                case 3
                    props = PublishProperties;
                case 4
                otherwise
                    error('mlpublish:InputParamErr', 'makeScatterFromNiis');
            end
            bx     = cell(length(xniis));
            by     = cell(length(yniis));
            xvecs  = cell(length(xniis));
            yvecs  = cell(length(yniis));
            mrimgs = cell(length(yniis));
            db     = mlfsl.Np797Registry.instance;
            for s = 1:length(xniis)
                assert(mlfourd.NIfTI.isNIfTI(fgniis{s}));
                assert(mlfourd.NIfTI.isNIfTI( xniis{s}));
                assert(mlfourd.NIfTI.isNIfTI( yniis{s}));
                fgnii     = ScatterPublisher.makeFg_noDataZeros(fgniis{s}, {xniis{s}}, {yniis{s}});
                bx{s}     = NiiBrowser( xniis{s}, db.petBlur);
                by{s}     = NiiBrowser( yniis{s}, db.mrBlur);
                xvecs{s}  = bx{s}.sampleVoxels(fgnii.img);
                yvecs{s}  = by{s}.sampleVoxels(fgnii.img);
                mrimgs{s} = yniis{s}.img;
            end
            obj        = ScatterPublisher.makeScatterFromCells(xvecs, yvecs, props, mrimgs);
        end % static factory makeScatterFromNiis
        
        %% Static  MAKEFG_NODATAZEROS modifies a single foreground mask so that zero-data
        %                     are never selected
        %  Usage:  fgnii1 = mlpublish.ScatterPublisher. ...
        %                   makeFg_noDataZeros(fgnii, dataniis, dataniis1)
        %          fgnii, *1:  NIfTI
        %          dataniis:   cell-array of NIfTI
        %          dataniis1:  optional
        function   fgnii1 = makeFg_noDataZeros(fgnii, dataniis, dataniis1)
            
            disp(['# voxels > eps -> ' num2str(sum(dip_image(fgnii.img) > eps))]);
            datapos = ones(size(dataniis{1}.img));
            for s = 1:length(dataniis)
                datapos = datapos     .* mostOfImg(dataniis{s});
                if (nargin > 2)
                    datapos = datapos .* mostOfImg(dataniis1{s});
                end
            end
            fgnii1  = mlfourd.NiiBrowser.make_nii_like(fgnii, ...
                datapos, 'mlpublish.ScatterPublisher.makeFg_noDataZeros');
            
            function mskimg = mostOfImg(nii)
                dipimg    = dip_image(nii.img);
                meanimg   = mean(dipimg);
                stdimg    =  std(dipimg);
                remainder = rem(meanimg, stdimg);
                mskimg    = double(dipimg > remainder);
                disp(['# voxels > mostOfImg.remainder -> ' num2str(sum(dipimg > remainder))]);
            end
        end % static function makeFg_noDataZeros
        
        %% Static  THRESHOLDROI and return a binary mask
        %  Usage:  binnii = mlpublish.ScatterPublisher. ...
        %                   thresholdRoi(fpnii, numstd)
        function   binnii = thresholdRoi(fpnii, numstd)
            
            dbase  = mlfsl.Np797Registry.instance;
            maxfp  = max(dip_image(fpnii.img))
            stdfp  = std(dip_image(fpnii.img))
            switch (nargin)
                case 1
                    thresh = maxfp;
                    for n = 1:floor(maxfp/stdfp)
                        thresh = thresh - stdfp;
                        coverage = sum(dip_image(double(fpnii.img > thresh)))/ ...
                            prod(fpnii.hdr.dime.dim(2:4));
                        if (coverage > 0.01)
                            break;
                        end
>>>>>>> .merge-right.r251
                    end
<<<<<<< .working
                    handlesRegress(i1)           = ...
                       plot(xspan,      regressed{i1}.fittedy, ...
                                        props.regressLines{i}, ...
                           'LineWidth', props.regressLineWidths{i}, ...
                           'Color',     props.lineColors{i});
                       plot(xspan,      regressed{i1}.pi, ...
                                        props.confidenceLines{i}, ...
                           'LineWidth', props.confidenceLineWidths{i}, ...
                           'Color',     props.lineColors{i});
                    i1 = i1 + 1;
                end
            end
            ScatterPublisher.diaryRegressions(regressed, props, ['plotScatter_' label]);
            if (props.globalRegression)  
                ScatterPublisher.plotGlobalScatterRegression(obj);
            end
            ScatterPublisher.refinePlotForPublication(props, handlesRegress);
            ScatterPublisher.printFigure(gcf, props);
            hold off;
        end % plotScatter
        
        
        function      gregressed = plotGlobalScatterRegression(obj)
            
            %% PLOTGLOBALSCATTERREGRESSION
            %  Usage:  obj = mlfourd.ScatterPublisher(props)
            %          obj = obj.plotGlobalScatterRegression;
            import mlpublish.*;
            % use local props, xv, yv in anticipation of conversion to handle class
                    props             = obj.publishProps;         % must be safe for copy by value & by ref
                    props.scatter     = true; 
                    props.BlandAltman = false;
             xv                    = obj.xv;
             yv                    = obj.yvecs;
            [xv, props]            = ScatterPublisher.rescaleVectors(xv, props);
            [yv, props]            = ScatterPublisher.rescaleVectors(yv, props, obj.mrimgs);
            pop    = 0;
            maxval = 0;
            N      = 0;
            for i = 1:length(xv)
                pop = pop + length(xv{i});
                if (max(xv{i}) > maxval); maxval = max(xv{i}); N = i; end
            end
            gxvec = zeros(pop,1); gyvec = zeros(pop,1); p = 1;
            for j = 1:length(xv)
                gxvec(p:(p+length(xv{j})-1)) = xv{j};
                gyvec(p:(p+length(yv{j})-1)) = yv{j};
                p = p + length(xv{j});
            end
            xincr  =    (max(xv{N}) - min(min(xv{N}, yv{N})))/length(xv{N});
            xspan  = min(min(xv{N}, yv{N})):xincr:max(xv{N});
            yincr  =    (max(yv{N}) - min(min(xv{N}, yv{N})))/length(yv{N});
            yspan  =                            0:yincr:max(yv{N});
            xspan1 =                            0:xincr:max(xv{N});
            try
                % options         = fitoptions('Normalize', 'on');
                [cfun gof fitout] = fit(gxvec, gyvec, props.libmodel);
            catch ME
                disp(ME.message);
                disp('calling fit with no options');
                [cfun gof fitout] = fit(gxvec, gyvec, props.libmodel);
            end
            gregressed.cfun    = cfun;
            gregressed.gof     = gof;
            gregressed.fitout  = fitout;
            gregressed.pi      = predint(cfun, xspan, ...
                                         props.confidenceInterval, 'functional', 'on');
            gregressed.fittedy = cfun.p1*xspan + cfun.p2;
            
            % global regression lines
            plot(xspan,       gregressed.fittedy, ...
                              props.regressLines{N}, ...
               'LineWidth', 3*props.regressLineWidths{N}, ...
               'Color',       props.axesColor);
            plot(xspan,       gregressed.pi, ...
                              props.confidenceLines{N}, ...
               'LineWidth', 4*props.confidenceLineWidths{N}, ...
               'Color',       props.axesColor);
           
            % statistics to report
            gregressed.meanx   = mean(gxvec);
            gregressed.stdx    = std( gxvec);
            gregressed.stderrx = std( gxvec)/sqrt(numel(gxvec));
            gregressed.meany   = mean(gyvec);            
            gregressed.stdy    = std( gyvec);
            gregressed.stderry = std( gyvec)/sqrt(numel(gyvec));
                
            % mean +/- std errors
            newlinecolor       = [0.5 0.5 0.5];
            newline            = 'k-';
            newdashes          = 'k:';
            newlinewidth       = 1.0;
            plot(xspan1, gregressed.meany + gregressed.stderry, ...
                              newdashes, ...
               'LineWidth',   newlinewidth, ...
               'Color',       newlinecolor);
            plot(xspan1, gregressed.meany,       ...
                              newline, ...
               'LineWidth',   newlinewidth, ...
               'Color',       props.axesColor);
            plot(xspan1, gregressed.meany - gregressed.stderry, ...
                              newdashes, ...
               'LineWidth',   newlinewidth, ...
               'Color',       newlinecolor);
            plot((gregressed.meanx - gregressed.stderrx)*ones(length(yspan),1), yspan, ...
                              newdashes, ...
               'LineWidth',   newlinewidth, ...
               'Color',       newlinecolor);
            plot( gregressed.meanx       *ones(length(yspan),1), yspan, ...
                              newline, ...
               'LineWidth',   newlinewidth, ...
               'Color',       newlinecolor);
            plot((gregressed.meanx + gregressed.stderrx)*ones(length(yspan),1), yspan, ...
                              newdashes, ...
               'LineWidth',   newlinewidth, ...
               'Color',       newlinecolor);
            ScatterPublisher.diaryRegressions(gregressed, props, 'plotGlobalScatterRegression');
        end % plotGlobalScatterRegression
        
        
        function      gregressed = plotGlobalBlandAltmanRegression(obj)
            
            %% Static  PLOTGLOBALBLANDALTMANREGRESSION
            %  Usage:  obj = mlfourd.ScatterPublisher(props)
            %          obj = obj.plotGlobalScatterRegression;
            import mlpublish.*;            
            % use local props, xv, yv in anticipation of conversion to handle class
             props             = obj.publishProps;               % must be safe for copy by value & by ref
             props.scatter     = false; 
             props.BlandAltman = true;
             xv         = obj.xvecs;
             yv         = obj.yvecs;
            [xv, props] = ScatterPublisher.rescaleVectors(xv, props);
            [yv, props] = ScatterPublisher.rescaleVectors(yv, props, obj.mrimgs);
            pop            = 0;
            maxval         = 0;
            N              = 0;
            for i = 1:length(xv)
                pop = pop + length(xv{i});
                if (max(xv{i}) > maxval); maxval = max(xv{i}); N = i; end
            end
            gxvec = zeros(pop,1); gyvec = zeros(pop,1); p = 1;
            for j = 1:length(xv)
                gxvec(p:(p+length(xv{j})-1)) = xv{j};
                gyvec(p:(p+length(yv{j})-1)) = yv{j};
                p = p + length(xv{j});
            end
            incr  =    (max(xv{N}) - min(min(xv{N}, yv{N})))/length(xv{N});
            xspan = min(min(xv{N}, yv{N})):incr:max(xv{N});
            
            %  Unique to Bland-Altman                 
            difference         = gyvec - gxvec;
            gregressed.meany   = mean(difference);
            gregressed.stdy    = std( difference);
            gregressed.confidy = 1.96*gregressed.stdy;
            onesy              = ones(length(xspan), 1);
            try
                % options           = fitoptions('Normalize', 'on');
                [cfun gof fitout] = fit(gxvec, gyvec, props.libmodel);
            catch ME
                disp(ME.message);
                disp('calling fit with no options');
                [cfun gof fitout] = fit(gxvec, gyvec, props.libmodel);
            end
            gregressed.cfun    = cfun;
            gregressed.gof     = gof;
            gregressed.fitout  = fitout;
            gregressed.pi      = predint(cfun, xspan, ...
                                         props.confidenceInterval, 'functional', 'on');
            gregressed.fittedy = cfun.p1*xspan + cfun.p2;
            
            % plot horizontal mean, confidence lines
            plot(xspan,       gregressed.meany*onesy, ...
                              props.regressLines{N}, ...
               'LineWidth', 3*props.regressLineWidths{N}, ...
               'Color',       props.axesColor);
            plot(xspan,      (gregressed.meany - gregressed.confidy)*onesy, ...
                              props.confidenceLines{N}, ...
               'LineWidth', 4*props.confidenceLineWidths{N}, ...
               'Color',       props.axesColor);
            plot(xspan,      (gregressed.meany + gregressed.confidy)*onesy, ...
                              props.confidenceLines{N}, ...
               'LineWidth', 4*props.confidenceLineWidths{N}, ...
               'Color',       props.axesColor);
            ScatterPublisher.diaryRegressions(gregressed, props, 'plotGlobalBlandAltmanRegression');
        end % plotGlobalBlandAltmanRegression
        
        
        function  handlesRegress = plotBlandAltman(obj,label)
            
            %% PLOTBLANDALTMAN
            %  Usage:  handlesRegress = plotBlandAltman(obj,label)
            %                                               ^ for diary
            % use local props, xv, yv in anticipation of conversion to handle class
            props = obj.publishProps;               % must be safe for copy by value & by ref
            props.scatter = false; 
            props.BlandAltman = true;
            if (~isempty(obj.publishProps.filestemEps))
                props.filestemEps = [obj.publishProps.filestemEps '_plotBlandAltman' label];
            end
             xv         = obj.xvecs;
             yv         = obj.yvecs;
            [xv, props] = ScatterPublisher.rescaleVectors(xv, props);
            [yv, props] = ScatterPublisher.rescaleVectors(yv, props, obj.mrimgs);
                       
            % plot main figure components   
            figure('Units', 'pixels', 'Position', ...
                   [props.offsetFromEdge props.offsetFromEdge ...
                    props.pixelSize props.pixelSize]);
            hold on;    
            sumrr = 0;
            for r = 1:length(props.regressionRequests)
                sumrr = sumrr + props.regressionRequests{r};
            end
            regressed      = cell(1, sumrr);
            scattered      = cell(1, length(xv));
            handlesRegress = zeros(  sumrr, 1);
            for i = 1:length(xv)
                difference           =  yv{i} - xv{i};
                average              = (yv{i} + xv{i})/2;
                scattered{i}         = plot(average, difference, props.markers{i});
                set(scattered{i}, 'MarkerSize',          props.markerArea{i}, ...
                                  'MarkerEdgeColor',     props.markerColors{i}); 
            end
            i1 = 1;
            for i = 1:length(xv)
                difference           =  yv{i} - xv{i};
                %%average              = (yv{i} + xv{i})/2;
                incr         = (max(xv{i}) - min(xv{i}))/length(xv{i});
                if (~isempty(props.anXLim))
                    xspan = (props.anXLim(1)):incr:(props.anXLim(2));
                else
                    xspan = min(xv{i}):incr:max(xv{i});
                end               
                regressed{i}.meany   = mean(difference);
                regressed{i}.stdy    = std( difference);
                regressed{i}.confidy = 1.96*regressed{i}.stdy;
                onesy                = ones(length(xspan), 1);                
                if (props.regressionRequests{i})
                    [cfun gof fitout]     = fit(xv{i}, yv{i}, props.libmodel);
                    regressed{i1}.cfun    = cfun;
                    regressed{i1}.gof     = gof;
                    regressed{i1}.fitout  = fitout;
                    regressed{i1}.pi      = predint(cfun, xspan, ...
                                                    props.confidenceInterval, 'functional', 'on');
                    regressed{i1}.fittedy = cfun.p1*xspan + cfun.p2;      
                    handlesRegress(i1) = ...
                       plot(xspan,      regressed{i}.meany*onesy, ...
                                        props.regressLines{i}, ...
                           'LineWidth', props.regressLineWidths{i}, ...
                           'Color',     props.lineColors{i});
                       plot(xspan,     (regressed{i}.meany - regressed{i}.confidy)*onesy, ...
                                        props.confidenceLines{i}, ...
                           'LineWidth', props.confidenceLineWidths{i}, ...
                           'Color',     props.lineColors{i});
                       plot(xspan,     (regressed{i}.meany + regressed{i}.confidy)*onesy, ...
                                        props.confidenceLines{i}, ...
                           'LineWidth', props.confidenceLineWidths{i}, ...
                           'Color',     props.lineColors{i});
                    i1 = i1 + 1;
                end
            end
            import mlpublish.*;
            
            % diaries
            ScatterPublisher.diaryRegressions(regressed, props, ['plotBlandAltman_' label]);
            if (props.globalRegression)  
                ScatterPublisher.plotGlobalBlandAltmanRegression(obj);
            end
            ScatterPublisher.refinePlotForPublication(props, handlesRegress);
            ScatterPublisher.printFigure(gcf, props);
            hold off;
        end % plotBloandAltman
        
        
        function tf     = checkProps(obj)  
            tf = obj.publishProps.checkSelf;
        end 
        
    end
     
    methods (Static) 
        
        function   obj = makeScatterFromFilenames(xfqfn, yfqfn, fgfqfn, props)
            
            %% MAKESCATTERFROMFILENAMES is a factory method; makes aplot from filenames
            %  Usage:  obj = ScatterPublisher. ...
            %                makeScatterFromFilenames(xfqfn, yfqfn, fgfqfn, props)
            %          xfqfn, yfqfn:  fully-qual. filenames for x & y data
            %          props:         plot properties              (option)
            %          fgfqfn:        fully-qual. filename of mask (option)
            %          obj:           ScatterPublisher instance
            %
            import mlpublish.*;  
            import mlfourd.*;
            switch (nargin)
                case 2
                    props = PublishProperties;
                    xnii  = mlfourd.NIfTI.load(xfqfn);
                    fgnii = xnii.ones;  
                case 3
                    xnii  = mlfourd.NIfTI.load(xfqfn);
                    fgnii = mlfourd.NIfTI.load(fgfqfn);
                case 4
                otherwise
                    error('mlpublish:InputParamsErr', ...
                         ['nargin -> ' num2str(nargin) ' is unsupported']);
            end
            ynii = mlfourd.NIfTI.load(yfqfn);
            obj  = ScatterPublisher.makeScatterFromNii(xnii, ynii, fgnii, props);
        end % static factory makeScatterFromFilenames
        
        function   obj = makeScatterFromNii(xnii,   ynii,   fgnii,  props)
            
            %% Static factory MAKESCATTERFROMNII makes a plot from NIfTI
            %  Usage:  obj = mlpublish.ScatterPublisher. ...
            %                makeScatterFromNii(xnii, ynii, fgnii, props)
            %
            import mlpublish.*;
            switch (nargin)
                case 2
                    props = PublishProperties;
                    fgnii = xnii.ones;
                case 3
                    props = PublishProperties;
                case 4
                otherwise
                    error('mlpublish:InputParamsErr', ...
                         ['nargin -> ' num2str(nargin) ' is unsupported']);
            end
            obj = ScatterPublisher.makeScatterFromNiis( ...
                                           {xnii}, {ynii}, {fgnii}, props);
        end % static factory makeScatterFromNii
        
        function   obj = makeScatterFromNiis(xniis, yniis, fgniis, props)
            
            %% MAKESCATTERFROMNIIS is a factory method;
            %                      plots from cell-arrays of matched data for publication.
            %  Usage:  obj = mlpublish.ScatterPublisher. ...
            %                makeScatterFromNiis(xniis, yniis, fgniis, props)
            %  Calls:  makeDefaultPrintProps
            %          isNIfTI
            %          makeFg
            %          NiiBrowser.ctor
            %          NiiBrowser.sampleVoxels
            %          makeScatterFromCells
            %
            import mlfourd.*;
            import mlpublish.*;
            switch (nargin)
                case 2
                    for s = 1:length(xniis); %#ok<*FORFLG>
                        fgniis{s} = xniis{1}.ones;
                    end
                    props  = mlpublish.PublishProperties('','', length(xniis));
                case 3                    
                    props  = mlpublish.PublishProperties('','', length(xniis));
                case 4
                otherwise
                    error('mlpublish:InputParamErr', 'makeScatterFromNiis');
            end       
            if (~iscell(xniis));  xniis  = {xniis}; end
            if (~iscell(yniis));  yniis  = {yniis}; end
            if (~iscell(fgniis)); fgniis = {fgniis}; end
            bx      = cell(length(xniis));
            by      = cell(length(yniis));
            xv      = cell(length(xniis));
            yv      = cell(length(yniis));
            mrimgs  = cell(length(yniis)); %#ok<*PROP>
            pbldr   = mlpet.PETBuilder;
            for s = 1:length(xniis)
                fgniis{s} = ScatterPublisher.makeFg(fgniis{s}, {xniis{s}}, {yniis{s}});
                bx{s}     = NiiBrowser( xniis{s}, pbldr.baseBlur);            
                by{s}     = NiiBrowser( yniis{s}, pbldr.baseBlur);
                xv{s}     = bx{s}.sampleVoxels(fgniis{s}.img);
                yv{s}     = by{s}.sampleVoxels(fgniis{s}.img);
                mrimgs{s} = yniis{s}.img;
            end            
            obj = ScatterPublisher.makeScatterFromCells(xv, yv, props, mrimgs);
        end % static factory makeScatterFromNiis
             
        
        function   obj = makeScatterFromVecs(xvec, yvec, props)
            
            %% MAKESCATTERFROMVECS is a factory method;
            %                     it plots vectors of matched data for publication
            %  Usage:  obj = mlpublish.ScatterPublisher. ...
            %                makeScatterFromVec(xvec,   yvec,  props)
            import mlpublish.*;
            if (~exist('props', 'var'))
                props = ScatterProperties;
            end
            obj = ScatterPublisher.makeScatterFromCells({xvec}, {yvec}, props);
        end % static factory makeScatterFromVecs
                
        function   obj = makeScatterFromCells(xv, yv, props, mrimgs)
            
            %% MAKESCATTERFROMCELLS is a factory;
            %                       plots data in matched cell-arrays of vectors
            %  Usage:  obj = mlpublish.ScatterPublisher. ...
            %                makeScatterFromCells(xv, yv, props)
            %          xv, yv:  cell arrays of double column-vectors of abscissa & ordinate values
            %          obj:           ScatterPublisher object
            %
            import mlpublish.*;
            switch (class(xv)) % convert numerics as convenience
                case 'double'
                    xv = {xv};
                case 'dip_image'
                    xv = {double(xv)};
                otherwise
                    assert(iscell(xv));
            end
            switch (class(yv)) % convert numerics as convenience
                case 'double'
                    yv = {yv};
                case 'dip_image'
                    yv = {double(yv)};
                otherwise
                    assert(iscell(yv));
            end
            assert(isa(props, 'ScatterProperties'));
            switch (nargin)
                case 3
                    obj = ScatterPublisher(props);
                    obj.checkVectors(xv, yv);
                case 4
                    obj = ScatterPublisher(props);
                    obj.mrimgs = mrimgs;
                    obj.checkVectors(xv, yv);
                otherwise
                    error('mlpublish:makeScatter:PassedParamsErr:numberOfParamsUnsupported', ...
                        'cf. doc mlpublish.ScatterPublisher.makeScatter');
            end
            assert(props.checkSelf);
                       
            %  Initialize figure components      
            if (props.numSeries ~= length(xv)); props.numSeries = length(xv); end
            obj.xvecs = cell(1, props.numSeries);
            obj.yvecs = cell(1, props.numSeries);
            obj.publishProps = props;
            obj.publishProps.regressionRequests = cell(1, props.numSeries);
            obj.publishProps.markers            = cell(1, props.numSeries);
            obj.publishProps.markerColors       = cell(1, props.numSeries);
            for i = 1:length(xv)
                obj.xvecs{i}                    = xv{i};
                obj.yvecs{i}                    = yv{i};
                obj.publishProps.regressionRequests{i} = props.regressionRequests{i};
                obj.publishProps.markers{i}            = props.markers{i};
                obj.publishProps.markerColors{i}       = props.markerColors{i};
            end
            if (isa(props, 'PublishProperties') && ~isa(props, 'BlandAltmanProperties'))
                obj.handlesScatter =     ScatterPublisher.plotScatter(obj); 
            end
            if (isa(props, 'BlandAltmanProperties'))                
                obj.handlesBlandAltman = ScatterPublisher.plotBlandAltman(obj); 
            end
        end % static factory makeScatterFromCells
        
        function          refinePlotForPublication(props, handles)
            
            %  Draw legend, title, axis labels              
            if (isfield(props, 'legendLabels') && ~isempty(props.legendLabels))
                if (~isfield(props, 'legendLocation'))
                    props.legendLocation = 'NorthEast';
                end
                if (~isempty(handles))
                    hlegend = legend(handles, props.legendLabels, 'location', props.legendLocation);
                    legend(hlegend, 'boxoff');
                end
            end
            if (isfield(props, 'aTitle'))
                htitle  = title(props.aTitle);
            end
            if (isa(props, 'mlpublish.BlandAltmanProperties'))
                hxlabel = xlabel(props.baXLabel);
                hylabel = ylabel(props.baYLabel);
            else
                hxlabel = xlabel(props.anXLabel);
                hylabel = ylabel(props.aYLabel);
            end
                           
            %  Refine GCA, GCF            
            set(gca, ...
                'FontName', props.gcaFontName, ...
                'Box', 'off', ...
                'TickDir', 'out', ...
                'TickLength', [props.tickLength, props.tickLength], ...
                'XMinorTick', 'on', ...
                'YMinorTick', 'on', ...
                'XColor', props.axesColor, ...
                'YColor', props.axesColor, ...
                'LineWidth', 1);
            set(gca, 'FontSize', props.gcaFontSize);
            
            if (~isempty(props.anXLim))
                xlim(props.anXLim);
            end
            if (~isempty(props.aYLim))
                ylim(props.aYLim);
            end
            
            if (isfield(props, 'aTitle'))
                set(htitle, 'FontName', props.titleFontName);
                set(htitle, 'FontSize', props.titleFontSize);
            end
            
            set([hxlabel, hylabel], 'FontName', props.axesFontName);
            set([hxlabel, hylabel], 'FontSize', props.axesFontSize);
            
            if (isfield(props, 'legendLabels') && numel(handles) > 0)
                set(hlegend, 'FontSize', props.legendFontSize);
            end
            
            set(gcf, ...
                'Color', 'white', ...
                'PaperPositionMode', 'auto');
            axis square;
        end % function refinePlotForPublication
               
        function metric = metricfind(str)
            
            %% METRICFIND returns the first recognizable metric in the passed string
            %  Usage:  metric = metricfind(str)
            %  See also:  strfind
            %
            if (    numel(strfind(lower(str), 'cbf'   )) > 0)
                metric = 'CBF';
            elseif (numel(strfind(lower(str), 'cbv'   )) > 0)
                metric = 'CBV';
            elseif (numel(strfind(lower(str), 'mtt'   )) > 0)
                metric = 'MTT';
            elseif (numel(strfind(lower(str), 'cmro2' )) > 0)
                metric = 'CMRO2';
            elseif (numel(strfind(lower(str), 'oef'   )) > 0)
                metric = 'OEF';
            elseif (numel(strfind(lower(str), 'counts')) > 0)
                metric = 'Counts';
            else
                metric = 'Unknown';
            end
        end % static function metricfind
        
        function props  = makeDefaultPrintProps            
            props = mlpublish.PublishProperties;           
        end % static function makeDefaultPrintProps
        
        function props  = makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba)
            
            %% MAKEPRINTPROPS generates a prototype of the props property used by 
            %                the ScatterPublisher class.
            %  Usage:  props = mlpublish.ScatterPublisher. ...
            %                  makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, numSeries)
            %          props = mlpublish.makeDefaultPrintProps
            %          xLbl, yLbl:  string for y-axis label
            %          ttl:         string for plot title
            %          
            %          filestm:     string for filename-stem of postscript and diary files
            %          lgdLbls:     cell array of strings for labels for the plot legend
            %                       pass integer to set numSeries
            %
            import mlpublish.*;
            switch (nargin)
                case 0
                    props = PublishProperties;
                case 1
                    props = PublishProperties(filestm);
                case 2
                    props = PublishProperties(filestm, ttl);
                case 3
                    props = PublishProperties(filestm, ttl);
                    props.anXLabel = xLbl;
                case 4
                    props = PublishProperties(filestm, ttl);
                    props.anXLabel = xLbl;
                    props.aYLabel  = yLbl;
                case 5
                    props = PublishProperties(filestm, ttl, length(lgdLbls));
                    props.anXLabel = xLbl;
                    props.aYLabel  = yLbl;
                case 6
                    props = PublishProperties(filestm, ttl, length(lgdLbls));
                    props.anXLabel = xLbl;
                    props.aYLabel  = yLbl;
                    props.baXLabel = xLbl_ba;
                case 7
                    props = PublishProperties(filestm, ttl, length(lgdLbls));
                    props.anXLabel = xLbl;
                    props.aYLabel  = yLbl;
                    props.baXLabel = xLbl_ba;
                    props.baYLabel = yLbl_ba;
                otherwise
                    error('mlpublish:PassedParamsErr:numberOfParamsUnsupported', ...
                          'ScatterPublisher.makePrintProps');
            end
            assert(props.checkSelf);
        end % static function makePrintProps
          
        function props  = makePrintProps3(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba)
            
            props = makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba);
        end 
=======
                case 2
                    thresh = maxfp - numstd*stdfp;
                otherwise
                    error('mlfourd:InputParamsErr', ...
                        ['RoiFactory.thresholdRoi does not support ' num2str(nargin) ' input params']);
            end
            bin    = double(fpnii.img > thresh);
            binnii = mlfourd.NiiBrowser.make_nii_like(fpnii, bin, 'RoiFactory.thresholdRoi');
        end % static function thresholdRoi
        
        %% Static factory MAKESCATTERFROMVEC plots vectors of matched data forpublication
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromVec(xvec,   yvec,  props)
        function   obj = makeScatterFromVecs( xvec,   yvec,  props)
            obj = mlpublish.ScatterPublisher.makeScatterFromCells({xvec}, {yvec}, props);
        end % static factory makeScatterFromVecs
        
        %% Static factory MAKESCATTERFROMCELLS plots data in matched cell-arrays of vectors
        %  Usage:  obj = mlpublish.ScatterPublisher. ...
        %                makeScatterFromCells(xvecs, yvecs, props)
        %          xvecs, yvecs:  cell arrays of double column-vectors of abscissa & ordinate values
        %          obj:           ScatterPublisher object
        function   obj = makeScatterFromCells(xvecs, yvecs, props, mrimgs)
            
            import mlpublish.*;
            switch (class(xvecs)) % convert numerics as convenience
                case 'double'
                    xvecs = {xvecs};
                case 'dip_image'
                    xvecs = {double(xvecs)};
                otherwise
                    assert(iscell(xvecs));
            end
            switch (class(yvecs)) % convert numerics as convenience
                case 'double'
                    yvecs = {yvecs};
                case 'dip_image'
                    yvecs = {double(yvecs)};
                otherwise
                    assert(iscell(yvecs));
            end
            switch (nargin)
                case 3
                    obj = ScatterPublisher(props);
                    obj.mrimgs = {};
                    obj.checkVectors(xvecs, yvecs);
                case 4
                    obj = ScatterPublisher(props);
                    obj.mrimgs = mrimgs;
                    obj.checkVectors(xvecs, yvecs);
                otherwise
                    error('mlpublish:makeScatter:PassedParamsErr:numberOfParamsUnsupported', ...
                        help('mlpublish.ScatterPublisher.makeScatter'));
            end
            
            %  Initialize figure components
            %%assert(isa(props, 'PublishProperties'));
            obj.xvecs = cell(1, sum(props.switches));
            obj.yvecs = cell(1, sum(props.switches));
            obj.props = props;
            obj.props.regressionRequests = cell(1, sum(props.switches));
            obj.props.markers            = cell(1, sum(props.switches));
            obj.props.markerColors       = cell(1, sum(props.switches));
            
            %  Trim cell-arrays according to props.switches
            i1    = 1
            for i = 1:length(xvecs)
                if (props.switches(i))
                    obj.xvecs{i1}                    = xvecs{i};
                    obj.yvecs{i1}                    = yvecs{i};
                    obj.props.regressionRequests{i1} = props.regressionRequests{i};
                    obj.props.markers{i1}            = props.markers{i};
                    obj.props.markerColors{i1}       = props.markerColors{i};
                    i1 = i1 + 1;
                end
            end
            obj.handlesScatter     = [];
            obj.handlesBlandAltman = [];
            scatter                = props.scatter;
            BlandAltman            = props.BlandAltman;
            if (isprop(props, 'scatter')     && scatter)
                obj.handlesScatter = ...
                    ScatterPublisher.plotScatter(obj);
            end
            if (isprop(props, 'BlandAltman') && BlandAltman)
                obj.handlesBlandAltman = ...
                    ScatterPublisher.plotBlandAltman(obj);
            end
        end % static factory makeScatterFromCells
        
        %% Static  REFINEPLOTFORPUBLICATION
        function   refinePlotForPublication(props, handles)
            
            %  Draw legend, title, axis labels
            props.checkSelf;
            if (isprop(props, 'legendLabels'))
                if (~isprop(props, 'legendLocation'))
                    props.legendLocation = 'NorthEast';
                end
                if (numel(handles) > 0)
                    hlegend = legend(handles, props.legendLabels, 'location', props.legendLocation);
                    legend(hlegend, 'boxoff');
                end
            end
            if (isprop(props, 'aTitle'))
                htitle  = title(props.aTitle);
            end
            if (isprop(props, 'BlandAltman') && props.BlandAltman)
                hxlabel = xlabel(props.anXLabel_BA);
                hylabel = ylabel(props.aYLabel_BA);
            else
                hxlabel = xlabel(props.anXLabel);
                hylabel = ylabel(props.aYLabel);
            end
            
            
            %  Refine GCA, GCF
            set(gca, ...
                'FontName', props.gcaFontName, ...
                'Box', 'off', ...
                'TickDir', 'out', ...
                'TickLength', [props.tickLength, props.tickLength], ...
                'XMinorTick', 'on', ...
                'YMinorTick', 'on', ...
                'XColor', props.axesColor, ...
                'YColor', props.axesColor, ...
                'LineWidth', 1);
            set(gca, 'FontSize', props.gcaFontSize);
            
            if (isprop(props, 'BlandAltman') && props.BlandAltman)
                if (isprop(props, 'anXLim_BA'))
                    xlim(props.anXLim_BA);
                end
                if (isprop(props, 'aYLim_BA'))
                    ylim(props.aYLim_BA);
                end
            else
                if (isprop(props, 'anXLim'))
                    xlim(props.anXLim);
                end
                if (isprop(props, 'aYLim'))
                    ylim(props.aYLim);
                end
            end
            
            if (isprop(props, 'aTitle'))
                set(htitle, 'FontName', props.titleFontName);
                set(htitle, 'FontSize', props.titleFontSize);
            end
            
            set([hxlabel, hylabel], 'FontName', props.axesFontName);
            set([hxlabel, hylabel], 'FontSize', props.axesFontSize);
            
            if (isfield(props, 'legendLabels') && numel(handles) > 0)
                set(hlegend, 'FontSize', props.legendFontSize);
            end
            
            set(gcf, ...
                'Color', 'white', ...
                'PaperPositionMode', 'auto');
            axis square;
        end % function refinePlotForPublication
        
        %% Static  METRICFIND returns the first recognizable metric in the passed string
        %  Usage:  metric = metricfind(str)
        %  See also:  strfind
        function   metric = metricfind(str)
            if (    numel(strfind(lower(str), 'cbf'   )) > 0)
                metric = 'CBF';
            elseif (numel(strfind(lower(str), 'cbv'   )) > 0)
                metric = 'CBV';
            elseif (numel(strfind(lower(str), 'mtt'   )) > 0)
                metric = 'MTT';
            elseif (numel(strfind(lower(str), 'cmro2' )) > 0)
                metric = 'CMRO2';
            elseif (numel(strfind(lower(str), 'oef'   )) > 0)
                metric = 'OEF';
            elseif (numel(strfind(lower(str), 'counts')) > 0)
                metric = 'Counts';
            else
                metric = 'Unknown';
            end
        end % static function metricfind
        
        %% Static  DEFAULTPRINTPROPS
        %  Usage:  props = mlpublish.ScatterPublisher. ...
        %                  defaultPrintProps(lenOrLegend)
        %          lenOrLegend:  numeric or cell of strings for legend
        function   props = defaultPrintProps(lenOrLegend)
            import mlpublish.*;
            switch (nargin)
                case 0
                    props = ScatterPublisher.makePrintProps;
                case 1
                    if (isnumeric(lenOrLegend))
                        len    = lenOrLegend;
                        legend = cell(1, len);
                        for i = 1:len
                            legend{i} = ['pt. ' num2str(i)];
                        end
                    elseif (iscell(lenOrLegend) && ~isempty(lenOrLegend) && ischar(lenOrLegend{1}))
                        len    = length(lenOrLegend);
                        legend = lenOrLegend;
                    else
                        error('InputParamsErr:UninterpretableParam', ...
                            'ScatterPublisher.defaultPrintProps');
                    end
                    props = ScatterPublisher.makePrintProps(...
                        ['makeDefaultPrintProps_len' num2str(len)], ...
                        '', ...
                        ['Perm.-Corrected PET CBF / ' ...
                        ScatterPublisher.unitsOfMeasurement({'pet' 'cbf'})], ...
                        ['MR CBF / ' ...
                        ScatterPublisher.unitsOfMeasurement({'mr'  'cbf'})], ...
                        legend);
                otherwise
                    error('InputParamsErr:TooManyArgs', ...
                        ['ScatterPublisher.defaultPrintProps received ' num2str(nargin) ' args']);
            end
        end % static function defaultPrintProps
        
        function   props = makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba)
            
            %% Static  MAKEPRINTPROPS generates a prototype of the props property used by
            %                         the ScatterPublisher class.
            %  Usage:  props = mlpublish.ScatterPublisher. ...
            %                  makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, numSeries)
            %
            %          props:       mlpublish.defaultPrintProps
            %          xLbl, yLbl:  string for y-axis label
            %          ttl:         string for plot title
            %
            %          filestm:     string for filename-stem of postscript and diary files
            %          lgdLbls:     cell array of strings for labels for the plot legend
            %                       pass integer to set numSeries
            %
            assert(iscell(lgdLbls));
            N = length(lgdLbls);
            props = mlpublish.PublishProperties(filestm, ttl, N);
            props.anXLabel = xLbl;
            props.aYLabel  = yLbl;
            props.legendLabels = lgdLbls;
            
            propsba = mlpublish.PublishProperties(filestm, ttl, N);
            propsba.anXLabel = xLbl_ba;
            propsba.aYLabel  = yLbl_ba;
            propsba.legendLabels = lgdLbls;
            
        end % function makePrintProps
        
>>>>>>> .merge-right.r251

<<<<<<< .working
        function props  = makePrintProps1(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba)
            
            props = makePrintProps(filestm, ttl, xLbl, yLbl, lgdLbls, xLbl_ba, yLbl_ba);   
        end 
        
        function tf     = checkVectors(xv, yv)
            
            %% CHECKVECTORS checks that any assignment to obj.xv and obj.yvecs
            %               meets the requirements of the ScatterPublisher class.
            %  Usage:  tf = ScatterPublisher. ...
            %                     checkVectors(xv, yv)
            %          xv, yv: cell-arrays of double column vectors
            %
            switch (nargin)
                case 2
                    assert(iscell(xv), ...
                        'mlpublish:checkProps:TypeErr:unrecognizedType', ...
                        ['type of xv was unexpected: ' class(xv)]);
                    assert(iscell(yv), ...
                        'mlpublish:checkProps:TypeErr:unrecognizedType', ...
                        ['type of yv was unexpected: ' class(yv)]);
                otherwise
                    error('mlpublish:PassedParamsErr:numberOfParamsUnsupported', ...
                        'cf. doc ScatterPublisher');
            end
            assert(isa(xv,'cell'), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of xv was unexpected: ' class(xv)]);
            assert(~isempty(xv), ...
                'mlpublish:checkVectors:EmptyParamErr', ...
                ['length(xv) was ' length(xv)]);
            assert(isnumeric(xv{1}), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType');
            %assert(~isempty(xv{1}), ...
            %    'mlpublish:checkVectors:EmptyParamErr', ...
            %    ['length(xv{1}) was ' length(xv{1})]);
            assert(isa(yv,'cell'), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of yv was unexpected: ' class(yv)]);
            assert(~isempty(yv), ...
                'mlpublish:checkVectors:EmptyParamErr', ...
                ['length(yv) was ' length(yv)]);
            assert(isnumeric(yv{1}), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of yv{1} was unexpected: ' class(yv{1})]);
            %assert(~isempty(yv{1}), ...
            %    'mlpublish:checkVectors:EmptyParamErr', ...
            %    ['length(yv{1}) was ' length(yv{1})]);
            assert(length(xv) == length(yv), ...
                'mlpublish:checkVectors:ParamInconsistencyErr');
            %assert(length(xv{1}) == length(yv{1}), ...
            %    'mlpublish:checkVectors:ParamInconsistencyErr', ...
            %    ['length(xv{1}) was ' length(xv{1}) ' but length(yv{1}) was ' length(yv{1})]);
            tf = true;
        end % static function checkVectors
        
        function          printFigure(gcf, props)
            
            %% PRINTFIGURE
            %  Usage:  ScatterPublisher.printFigure(h, props)
            %                                       ^ figure handle, e.g., gcf
            %                                          ^ PublishProperties object
            %
            if (~isempty(props.filestemEps))
                try
                    disp(['Printing EPSC2 in CMYK at ' num2str(props.dpi) ' dpi to ' props.filestemEps '.eps..........']);
                    print(gcf, '-depsc2', '-cmyk', ['-r' num2str(props.dpi)], [props.filestemEps '.eps']); %#ok<*MCPRT>
                catch ME %#ok<*MUCTH>
                    disp(ME.message);
                    warning('mpublish:PrintingErr', ...
                        ['printFigure failed to write postscript file ' ...
                          props.filestemEps '.eps ']);
                end
            end
        end % static function printFigure     
        
        function          diaryRegressions(regressed, props, desc)
            
            %% DIARYREGRESSIONS writes diaries with regression information
            %  Usage:  ScatterPublisher. ...
            %          diaryRegressions(regressed, props, desc)
            %
            %          add extra information to field props.comments, which will be displayed
            %
            if (~iscell(regressed)); regressed = {regressed}; end
            if (~isempty(props.filestemEps))
                    diary([props.filestemEps '_' desc '.txt']);
                    disp(['length(regressed) -> ' num2str(length(regressed))]);
                    for i = 1:length(regressed) %#ok<*FORPF>
                        try
                            if (logical(strmatch('legendLabels', fieldnames(props))))
                                fprintf('legendLabels{%g}       -> \n', i);
                                disp(props.legendLabels{i});
                            end
                            if (isfield(regressed{i},              'spearrho'))
                                fprintf('regressed{%g}.spearrho -> \n', i);
                                disp(regressed{i}.spearrho);
                            end
                            if (isfield(regressed{i},              'pval'))
                                fprintf('regressed{%g}.pval     -> \n', i);
                                disp(regressed{i}.pval);
                            end
                            if (isfield(regressed{i},              'cfun'))
                                fprintf('regressed{%g}.cfun     -> \n', i);
                                disp(regressed{i}.cfun);
                            end
                            if (isfield(regressed{i},              'gof'))
                                fprintf('regressed{%g}.gof      -> \n', i);
                                disp(regressed{i}.gof);
                            end
                            if (isfield(regressed{i},              'fitout'))
                                fprintf('regressed{%g}.fitout   -> \n', i);
                                disp(regressed{i}.fitout);
                            end
                            if (isfield(regressed{i},              'meanx'))
                                fprintf('regressed{%g}.meanx    -> %g\n', i, regressed{i}.meanx);
                            end
                            if (isfield(regressed{i},              'stdx'))
                                fprintf('regressed{%g}.stdx     -> %g\n', i, regressed{i}.stdx);
                            end
                            if (isfield(regressed{i},              'stderrx'))
                                fprintf('regressed{%g}.stderrx  -> %g\n', i, regressed{i}.stderrx);
                            end
                            if (isfield(regressed{i},              'confidx'))
                                fprintf('regressed{%g}.confidx  -> %g\n', i, regressed{i}.confidx);
                            end
                            if (isfield(regressed{i},              'meany'))
                                fprintf('regressed{%g}.meany    -> %g\n', i, regressed{i}.meany);
                            end
                            if (isfield(regressed{i},              'stdy'))
                                fprintf('regressed{%g}.stdy     -> %g\n', i, regressed{i}.stdy);
                            end
                            if (isfield(regressed{i},              'stderry'))
                                fprintf('regressed{%g}.stderry  -> %g\n', i, regressed{i}.stderry);
                            end
                            if (isfield(regressed{i},              'confidy'))
                                fprintf('regressed{%g}.confidy  -> %g\n', i, regressed{i}.confidy);
                            end
                            if (isfield(regressed{i},              'comments'))
                                fprintf('regressed{%g}.comments -> %s\n', i, regressed{i}.comments);
                            end
                        catch ME
                           disp(ME.message);
                           warning('mpublish:PrintingErr', ...
                               ['diaryRegressions failed to write diary file ' ...
                                 props.filestemEps '.txt']);
                        end
=======
        

        
        function   triplet = colorTripletField(x, N)
            % DEPRECATED
            triplet = mlpublish.PublishProperties.rgbWarpedValue(x, N);
        end % function colorTripletField
        
        %% Static  CHECKPROPS checks that any assignment to obj.props meets the requirements of the ScatterPublisher class.
        %  Usage:  truthVal = mlpublish.ScatterPublisher. ...
        %                     checkProps(prps)
        %          prps:  a property struct
        %
        %  DEPRECATED
        %
        function   truthVal = checkProps(prps)
            truthVal = 1;     
        end % static funcion checkProps
        
        %% Static  CHECKVECTORS checks that any assignment to obj.xvecs and obj.yvecs
        %                       meets the requirements of the ScatterPublisher class.
        %  Usage:  truthval = mlpublish.ScatterPublisher. ...
        %                     checkVectors(xvecs, yvecs)
        %          xvecs, yvecs: cell-arrays of double column vectors
        function   truthval = checkVectors(xvecs, yvecs)
            
            switch (nargin)
                case 2
                    assert(iscell(xvecs), ...
                        'mlpublish:checkProps:TypeErr:unrecognizedType', ...
                        ['type of xvecs was unexpected: ' class(xvecs)]);
                    assert(iscell(yvecs), ...
                        'mlpublish:checkProps:TypeErr:unrecognizedType', ...
                        ['type of yvecs was unexpected: ' class(yvecs)]);
                otherwise
                    error('mlpublish:PassedParamsErr:numberOfParamsUnsupported', ...
                        help('mlpublish.ScatterPublisher.checkProps'));
            end
            assert(isa(xvecs,'cell'), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of xvecs was unexpected: ' class(xvecs)]);
            assert(~isempty(xvecs), ...
                'mlpublish:checkVectors:EmptyParamErr', ...
                ['length(xvecs) was ' length(xvecs)]);
            assert(isnumeric(xvecs{1}), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType');
            %assert(~isempty(xvecs{1}), ...
            %    'mlpublish:checkVectors:EmptyParamErr', ...
            %    ['length(xvecs{1}) was ' length(xvecs{1})]);
            assert(isa(yvecs,'cell'), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of yvecs was unexpected: ' class(yvecs)]);
            assert(~isempty(yvecs), ...
                'mlpublish:checkVectors:EmptyParamErr', ...
                ['length(yvecs) was ' length(yvecs)]);
            assert(isa(yvecs{1},'double'), ...
                'mlpublish:checkVectors:TypeErr:unrecognizedType', ...
                ['type of yvecs{1} was unexpected: ' class(yvecs{1})]);
            %assert(~isempty(yvecs{1}), ...
            %    'mlpublish:checkVectors:EmptyParamErr', ...
            %    ['length(yvecs{1}) was ' length(yvecs{1})]);
            assert(length(xvecs) == length(yvecs), ...
                'mlpublish:checkVectors:ParamInconsistencyErr');
            disp(['length(xvecs) was ' num2str(length(xvecs)) ...
                '; length(yvecs) was ' num2str(length(yvecs))]);
            %assert(length(xvecs{1}) == length(yvecs{1}), ...
            %    'mlpublish:checkVectors:ParamInconsistencyErr', ...
            %    ['length(xvecs{1}) was ' length(xvecs{1}) ' but length(yvecs{1}) was ' length(yvecs{1})]);
            truthval = true;
        end % static function checkVectors
        
        %% Static  PRINTFIGURE
        function   printFigure(gcf, props)
            if (isfield(props, 'filenameStemEps') && ~isempty(props.filenameStemEps))
                try
                    disp(['Printing EPSC2 in CMYK at ' num2str(props.dpi) ' dpi to ' props.filenameStemEps '.eps..........']);
                    print(gcf, '-depsc2', '-cmyk', ['-r' num2str(props.dpi)], [props.filenameStemEps '.eps']);
                catch ME
                    disp(ME.message);
                    warning('mpublish:PrintingErr', ...
                        ['printFigure failed to write postscript file ' ...
                        props.filenameStemEps '.eps ']);
                end
            end
        end % static function printFigure
        
        %% Static  DIARYREGRESSIONS writes diaries with regression information
        %  Usage:  mlpublish.ScatterPublisher. ...
        %          diaryRegressions(regressed, props, desc)
        %
        %          add extra information to field props.comments, which will be displayed
        function   diaryRegressions(regressed, props, desc)
            
            if (~iscell(regressed)); regressed = {regressed}; end
            if (isfield(props, 'filenameStemEps') && ~isempty(props.filenameStemEps))
                diary([props.filenameStemEps '_' desc '.txt']);
                disp(['length(regressed) -> ' num2str(length(regressed))]);
                for i = 1:length(regressed)
                    try
                        if (isfield(props, 'legendLabels'))
                            disp(['legendLabels{' num2str(i) '}          -> ' ...
                                props.legendLabels{i}]);
                        end
                        if (isfield(regressed{i},              'cfun'))
                            disp(['regressed{'    num2str(i) '}.cfun     -> ']); regressed{i}.cfun
                        end
                        if (isfield(regressed{i},              'gof'))
                            disp(['regressed{'    num2str(i) '}.gof      -> ']); regressed{i}.gof
                        end
                        if (isfield(regressed{i},              'fitout'))
                            disp(['regressed{'    num2str(i) '}.fitout   -> ']); regressed{i}.fitout
                        end
                        if (isfield(regressed{i},              'meanx'))
                            disp(['regressed{'    num2str(i) '}.meanx    -> ']); regressed{i}.meanx
                        end
                        if (isfield(regressed{i},              'stdx'))
                            disp(['regressed{'    num2str(i) '}.stdx     -> ']); regressed{i}.stdx
                        end
                        if (isfield(regressed{i},              'stderrx'))
                            disp(['regressed{'    num2str(i) '}.stderrx     -> ']); regressed{i}.stderrx
                        end
                        if (isfield(regressed{i},              'confidx'))
                            disp(['regressed{'    num2str(i) '}.confidx  -> ']); regressed{i}.confidx
                        end
                        if (isfield(regressed{i},              'meany'))
                            disp(['regressed{'    num2str(i) '}.meany    -> ']); regressed{i}.meany
                        end
                        if (isfield(regressed{i},              'stdy'))
                            disp(['regressed{'    num2str(i) '}.stdy     -> ']); regressed{i}.stdy
                        end
                        if (isfield(regressed{i},              'stderry'))
                            disp(['regressed{'    num2str(i) '}.stderry     -> ']); regressed{i}.stderry
                        end
                        if (isfield(regressed{i},              'confidy'))
                            disp(['regressed{'    num2str(i) '}.confidy  -> ']); regressed{i}.confidy
                        end
                        if (isfield(regressed{i},              'comments'))
                            disp(['regressed{'    num2str(i) '}.comments -> ']); regressed{i}.comments
                        end
                    catch ME
                        disp(ME.message);
                        warning('mpublish:PrintingErr', ...
                            ['diaryRegressions failed to write diary file ' ...
                            props.filenameStemEps '.txt']);
>>>>>>> .merge-right.r251
                    end
<<<<<<< .working
                    %disp('top level of props:');
                    %props
                    disp('-------------------------------------------- end diary entry ----------------------------------------------');
                    diary off;
                
            end
        end % static function diaryRegressions
        
        function          units  = unitsOfMeasurement(tags)            
            units = mlpublish.PublishProperties.unitsOfMeasurement(tags);      
        end % static function unitsOfMeasurement        
        
        function [vcells, props] = rescaleVectors(vcells, props, mrimgs, white_filename)
            
            %% RESCALEVECTORS
            %  Usage:  [vcells, props] = rescaleVectors(vcells, props, mrimgs, white_filename)
            import mlfourd.* mlfsl.*;
            dbase = Np797Registry.instance;
            if (nargin < 3); mrimgs = {}; end
            
            if (dbase.rescaleWhiteMatter && ...
                numel(mrimgs)            && ...
                dbase.iscomparator) % for rescaling wrt superior white-matter slices
                masknii  = NIfTI.load(white_filename); 
                overlap  = 0;
                bestcell = 0;
                for i = 1:length(vcells)
                    overlap1 = sum(sum(sum(sum(masknii.img .* mrimgs{i}))));
                    if (overlap1 > overlap)
                        overlap  = overlap1; 
                        bestcell = i;
=======
                end
                disp('top level of props:');
                props
                disp('-------------------------------------------- end diary entry ----------------------------------------------');
                diary off;
                
            end
        end % static function diaryRegressions
        
        %% Static  UNITSOFMEASUREMENT returns units of measurement for each of the data tags
        %  Usage:  units = mlpublish.ScatterPublisher. ...
        %                  unitsOfMeasurement(tags)
        %          tags:   cell-array of strings describing the data,
        %                  e. g., {'pet', 'cbf'}
        %          units:  string descriptor, e. g., 'ml/min/100 g'
        function   units = unitsOfMeasurement(tags)
            
            assert(1 == nargin);
            assert(iscell(tags));
            for t = 1:length(tags)
                assert(ischar(tags{t}));
            end
            
            switch (lower(tags{1}))
                case 'pet'
                    switch (lower(tags{2}))
                        case 'cbf'
                            units = '(mL/min/100 g)';
                        case 'cbv'
                            units = '(mL/100 g)';
                        case 'mtt'
                            units = 's';
                        case 'oef'
                            units = 'Dimensionless';
                        case 'cmro2'
                            units = '--';
                        otherwise
                            error('mlpublish:InternalDataErr', ...
                                ['tags{2} -> ' tags{2} ' was unrecognizable']);
>>>>>>> .merge-right.r251
                    end
<<<<<<< .working
                end
                OFFSET = 3; % find rostral-most white-matter sample
                zmax   = size(mrimgs{bestcell},3);
                sqimg = squeeze(mrimgs{bestcell});
                slimg = dip_image(squeeze(double(sqimg(:,:,zmax-OFFSET))));
                sqmsk =           squeeze(masknii.img);
                slmsk = dip_image(squeeze(double(sqmsk(:,:,zmax-OFFSET))));
                dbase.whiteMatterAverage = sum(slimg.*slmsk)/sum(slmsk);
                for i = 1:length(vcells)
                    vcells{i} = vcells{i} * ...
                        dbase.assumedWhiteAverage / dbase.whiteMatterAverage;
                end
            end
            if (strcmp(props.rescale, 'to_mean'))
                for i = 1:length(vcells)
                   vcells{i} = vcells{i}/mean(vcells{i}) - 1;
                end
            end
            if (strcmp(props.rescale, 'std_moment'))
                for i = 1:length(vcells)
                   vcells{i} = (vcells{i} - mean(vcells{i}))/std(vcells{i});
                end
            end
        end % static function rescaleVectors

    end % static methods
=======
                case {'mr mlem', 'mrmlem', 'mlem', 'mr svd', 'mrsvd', 'svd', 'mr'}
                    switch (lower(tags{2}))
                        case 'cbf'
                            units = 'Arbitrary';
                        case 'qcbf'
                            units = '(mL/min/100 g)';
                        case 'cbv'
                            units = 'Arbitrary';
                        case 'qcbv'
                            units = '(mL/100 g)';
                        case 'mtt'
                            units = 'Arbitrary';
                        case 'qmtt'
                            units = 's';
                        otherwise
                            error('mlpublish:InternalDataErr', ...
                                ['tags{2} -> ' tags{2} ' was unrecognizable']);
                    end
                case {'mr laif' 'mrlaif' 'laif'}
                    switch (lower(tags{2}))
                        case 'cbf'
                            units = 'Arbitrary';
                        case 'cbv'
                            units = 'Arbitrary';
                        case 'mtt'
                            units = 's';
                        otherwise
                            error('mlpublish:InternalDataErr', ...
                                ['tags{2} -> ' tags{2} ' was unrecognizable']);
                    end
                otherwise
                    error('mlpublish:InternalDataErr', ...
                        ['tags{1} -> ' tags{1} ' was unrecognizable']);
            end
        end % static function unitsOfMeasurement
        
        %% Static  RESCALEVECTORS
        %  Usage:  [vcells, props] = rescaleVectors(vcells, props, mrimgs, white_filename)
        function   [vcells, props] = rescaleVectors(vcells, props, mrimgs, white_filename)
            
            import mlfourd.* mlfsl.*;
            dbase = Np797Registry.instance;
            if (nargin < 3); mrimgs = {}; end
            
            if (dbase.rescaleWhiteMatter && ...
                    numel(mrimgs)            && ...
                    dbase.iscomparator) % for rescaling wrt superior white-matter slices
                masknii  = load_nii(white_filename);
                overlap  = 0;
                bestcell = 0;
                for i = 1:length(vcells)
                    overlap1 = sum(sum(sum(sum(masknii.img .* mrimgs{i}))));
                    if (overlap1 > overlap)
                        overlap  = overlap1;
                        bestcell = i;
                    end
                end
                OFFSET = 3; % find rostral-most white-matter sample
                zmax   = size(mrimgs{bestcell},3);
                sqimg = squeeze(mrimgs{bestcell});
                slimg = dip_image(squeeze(double(sqimg(:,:,zmax-OFFSET))));
                sqmsk =           squeeze(masknii.img);
                slmsk = dip_image(squeeze(double(sqmsk(:,:,zmax-OFFSET))));
                dbase.whiteMatterAverage = sum(slimg.*slmsk)/sum(slmsk);
                for i = 1:length(vcells)
                    vcells{i} = vcells{i} * ...
                        dbase.assumedWhiteAverage / dbase.whiteMatterAverage;
                end
            end
            if ((isfield(props, 'rescale_to_mean')    && props.rescale_to_mean    && props.scatter) || ...
                    (isfield(props, 'rescale_BA_to_mean') && props.rescale_BA_to_mean && props.BlandAltman))
                for i = 1:length(vcells)
                    vcells{i} = vcells{i}/mean(vcells{i}) - 1;
                end
            end
            if ((isfield(props, 'stdMoment')    && props.stdMoment    && props.scatter) || ...
                    (isfield(props, 'stdMoment_BA') && props.stdMoment_BA && props.BlandAltman))
                for i = 1:length(vcells)
                    vcells{i} = (vcells{i} - mean(vcells{i}))/std(vcells{i});
                end
            end
        end % static function rescaleVectors
        
        %% Static  PLOTSCATTER
        %  Usage:  handlesRegress = plotScatter(obj)
        function   handlesRegress = plotScatter(obj)
            
            import mlpublish.*;
            % use local props, xvecs, yvecs in anticipation of conversion to handle class
            props                 = obj.props;               % must be safe for copy by value & by ref
            props.scatter         = true;
            props.BlandAltman     = false;
            props.filenameStemEps = [obj.props.filenameStemEps '_plotScatter'];
            xvecs         = obj.xvecs;
            yvecs         = obj.yvecs;
            [xvecs, props] = ScatterPublisher.rescaleVectors(xvecs, props);
            [yvecs, props] = ScatterPublisher.rescaleVectors(yvecs, props, obj.mrimgs);
            
            % plot main figure components
            figure('Units', 'pixels', 'Position', ...
                [props.offsetFromEdge props.offsetFromEdge ...
                props.pixelSize      props.pixelSize]);
            hold on;
            sumrr = 0;
            for r = 1:length(props.regressionRequests)
                sumrr = sumrr + props.regressionRequests{r};
            end
            regressed      = cell(1, sumrr);
            scattered      = cell(1, length(xvecs));
            handlesRegress = zeros(  sumrr, 1);
            i1 = 1;
            for i = 1:length(xvecs)
                incr         =    (max(xvecs{i}) - min(min(xvecs{i}, yvecs{i})))/length(xvecs{i});
                xspan        = min(min(xvecs{i}, yvecs{i})):incr:max(xvecs{i});
                scattered{i} =    plot(xvecs{i}, yvecs{i}, props.markers{i});
                set(scattered{i}, 'MarkerSize',            props.markerArea{i}, ...
                    'MarkerEdgeColor',       props.markerColors{i});
                if (props.regressionRequests{i})
                    try
                        % options           = fitoptions('Normalize', 'on');
                        [cfun gof fitout] = fit(xvecs{i}, yvecs{i}, 'poly1');
                    catch ME
                        disp(ME.message);
                        disp('calling fit with no options');
                        [cfun gof fitout] = fit(xvecs{i}, yvecs{i}, 'poly1');
                    end
                    regressed{i1}.cfun    = cfun;
                    regressed{i1}.gof     = gof;
                    regressed{i1}.fitout  = fitout;
                    regressed{i1}.pi      = predint(cfun, xspan, ...
                        props.confidenceInterval, 'functional', 'on');
                    regressed{i1}.fittedy = cfun.p1*xspan + cfun.p2;
                    handlesRegress(i1)           = ...
                        plot(xspan,      regressed{i1}.fittedy, ...
                        props.regressLines{i}, ...
                        'LineWidth', props.regressLineWidths{i}, ...
                        'Color',     props.lineColors{i});
                    plot(xspan,      regressed{i1}.pi, ...
                        props.confidenceLines{i}, ...
                        'LineWidth', props.confidenceLineWidths{i}, ...
                        'Color',     props.lineColors{i});
                    i1 = i1 + 1;
                end
            end
            ScatterPublisher.diaryRegressions(regressed, props, 'plotScatter');
            if (props.globalRegression)
                ScatterPublisher.plotGlobalScatterRegression(obj);
            end
            ScatterPublisher.refinePlotForPublication(props, handlesRegress);
            ScatterPublisher.printFigure(gcf, props);
            hold off;
        end % static function plotScatter
        
        %% Static  PLOTGLOBALSCATTERREGRESSION
        %  Usage:  obj = mlfourd.ScatterPublisher(props)
        %          obj = obj.plotGlobalScatterRegression;
        function   gregressed = plotGlobalScatterRegression(obj)
            
            import mlpublish.*;
            % use local props, xvecs, yvecs in anticipation of conversion to handle class
            props             = obj.props;         % must be safe for copy by value & by ref
            props.scatter     = true;
            props.BlandAltman = false;
            xvecs                    = obj.xvecs;
            yvecs                    = obj.yvecs;
            [xvecs, props]            = ScatterPublisher.rescaleVectors(xvecs, props);
            [yvecs, props]            = ScatterPublisher.rescaleVectors(yvecs, props, obj.mrimgs);
            pop    = 0;
            maxval = 0;
            N      = 0;
            for i = 1:length(xvecs)
                pop = pop + length(xvecs{i});
                if (max(xvecs{i}) > maxval); maxval = max(xvecs{i}); N = i; end
            end
            gxvec = zeros(pop,1); gyvec = zeros(pop,1); p = 1;
            for j = 1:length(xvecs)
                gxvec(p:(p+length(xvecs{j})-1)) = xvecs{j};
                gyvec(p:(p+length(yvecs{j})-1)) = yvecs{j};
                p = p + length(xvecs{j});
            end
            xincr  =    (max(xvecs{N}) - min(min(xvecs{N}, yvecs{N})))/length(xvecs{N});
            xspan  = min(min(xvecs{N}, yvecs{N})):xincr:max(xvecs{N});
            yincr  =    (max(yvecs{N}) - min(min(xvecs{N}, yvecs{N})))/length(yvecs{N});
            yspan  =                            0:yincr:max(yvecs{N});
            xspan1 =                            0:xincr:max(xvecs{N});
            try
                % options         = fitoptions('Normalize', 'on');
                [cfun gof fitout] = fit(gxvec, gyvec, 'poly1');
            catch ME
                disp(ME.message);
                disp('calling fit with no options');
                [cfun gof fitout] = fit(gxvec, gyvec, 'poly1');
            end
            gregressed.cfun    = cfun;
            gregressed.gof     = gof;
            gregressed.fitout  = fitout;
            gregressed.pi      = predint(cfun, xspan, ...
                props.confidenceInterval, 'functional', 'on');
            gregressed.fittedy = cfun.p1*xspan + cfun.p2;
            
            % global regression lines
            plot(xspan,       gregressed.fittedy, ...
                props.regressLines{N}, ...
                'LineWidth', 1.5*props.regressLineWidths{N}, ...
                'Color',       props.axesColor);
            plot(xspan,       gregressed.pi, ...
                props.confidenceLines{N}, ...
                'LineWidth', 1.5*props.confidenceLineWidths{N}, ...
                'Color',       props.axesColor);
            
            % statistics to report
            gregressed.meanx   = mean(gxvec);
            gregressed.stdx    = std( gxvec);
            gregressed.stderrx = std( gxvec)/sqrt(numel(gxvec));
            gregressed.meany   = mean(gyvec);
            gregressed.stdy    = std( gyvec);
            gregressed.stderry = std( gyvec)/sqrt(numel(gyvec));
            
            % mean +/- std errors
            newlinecolor       = [0.5 0.5 0.5];
            newline            = 'k-';
            newdashes          = 'k:';
            newlinewidth       = 1.0;
            %             plot(xspan1, gregressed.meany + gregressed.stderry, ...
            %                               newdashes, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       newlinecolor);
            %             plot(xspan1, gregressed.meany,       ...
            %                               newline, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       props.axesColor);
            %             plot(xspan1, gregressed.meany - gregressed.stderry, ...
            %                               newdashes, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       newlinecolor);
            %             plot((gregressed.meanx - gregressed.stderrx)*ones(length(yspan),1), yspan, ...
            %                               newdashes, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       newlinecolor);
            %             plot( gregressed.meanx       *ones(length(yspan),1), yspan, ...
            %                               newline, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       newlinecolor);
            %             plot((gregressed.meanx + gregressed.stderrx)*ones(length(yspan),1), yspan, ...
            %                               newdashes, ...
            %                'LineWidth',   newlinewidth, ...
            %                'Color',       newlinecolor);
            ScatterPublisher.diaryRegressions(gregressed, props, 'plotGlobalScatterRegression');
        end % static function plotGlobalScatterRegression
        
        %% Static  PLOTGLOBALBLANDALTMANREGRESSION
        %  Usage:  obj = mlfourd.ScatterPublisher(props)
        %          obj = obj.plotGlobalScatterRegression;
        function   gregressed = plotGlobalBlandAltmanRegression(obj)
            
            import mlpublish.*;
            % use local props, xvecs, yvecs in anticipation of conversion to handle class
            props             = obj.props;               % must be safe for copy by value & by ref
            props.scatter     = false;
            props.BlandAltman = true;
            xvecs         = obj.xvecs;
            yvecs         = obj.yvecs;
            [xvecs, props] = ScatterPublisher.rescaleVectors(xvecs, props);
            [yvecs, props] = ScatterPublisher.rescaleVectors(yvecs, props, obj.mrimgs);
            pop            = 0;
            maxval         = 0;
            N              = 0;
            for i = 1:length(xvecs)
                pop = pop + length(xvecs{i});
                if (max(xvecs{i}) > maxval); maxval = max(xvecs{i}); N = i; end
            end
            gxvec = zeros(pop,1); gyvec = zeros(pop,1); p = 1;
            for j = 1:length(xvecs)
                gxvec(p:(p+length(xvecs{j})-1)) = xvecs{j};
                gyvec(p:(p+length(yvecs{j})-1)) = yvecs{j};
                p = p + length(xvecs{j});
            end
            incr  =    (max(xvecs{N}) - min(min(xvecs{N}, yvecs{N})))/length(xvecs{N});
            xspan = min(min(xvecs{N}, yvecs{N})):incr:max(xvecs{N});
            
            %  Unique to Bland-Altman
            difference         = gyvec - gxvec;
            gregressed.meany   = mean(difference);
            gregressed.stdy    = std( difference);
            gregressed.confidy = 1.96*gregressed.stdy;
            onesy              = ones(length(xspan), 1);
            try
                % options           = fitoptions('Normalize', 'on');
                [cfun gof fitout] = fit(gxvec, gyvec, 'poly1');
            catch ME
                disp(ME.message);
                disp('calling fit with no options');
                [cfun gof fitout] = fit(gxvec, gyvec, 'poly1');
            end
            gregressed.cfun    = cfun;
            gregressed.gof     = gof;
            gregressed.fitout  = fitout;
            gregressed.pi      = predint(cfun, xspan, ...
                props.confidenceInterval, 'functional', 'on');
            gregressed.fittedy = cfun.p1*xspan + cfun.p2;
            
            % plot horizontal mean, confidence lines
            plot(xspan,       gregressed.meany*onesy, ...
                props.regressLines{N}, ...
                'LineWidth', 1.5*props.regressLineWidths{N}, ...
                'Color',       props.axesColor);
            plot(xspan,      (gregressed.meany - gregressed.confidy)*onesy, ...
                props.confidenceLines{N}, ...
                'LineWidth', 1.5*props.confidenceLineWidths{N}, ...
                'Color',       props.axesColor);
            plot(xspan,      (gregressed.meany + gregressed.confidy)*onesy, ...
                props.confidenceLines{N}, ...
                'LineWidth', 1.5*props.confidenceLineWidths{N}, ...
                'Color',       props.axesColor);
            ScatterPublisher.diaryRegressions(gregressed, props, 'plotGlobalBlandAltmanRegression');
        end % static function plotGlobalBlandAltmanRegression
        
        %% Static  PLOTBLANDALTMAN
        %  Usage:  handlesRegress = plotBlandAltman(obj)
        function   handlesRegress = plotBlandAltman(obj)
            
            % use local props, xvecs, yvecs in anticipation of conversion to handle class
            props = obj.props;               % must be safe for copy by value & by ref
            props.scatter = false;
            props.BlandAltman = true;
            props.filenameStemEps = [obj.props.filenameStemEps '_plotBlandAltman'];
            xvecs         = obj.xvecs;
            yvecs         = obj.yvecs;
            [xvecs, props] = ScatterPublisher.rescaleVectors(xvecs, props);
            [yvecs, props] = ScatterPublisher.rescaleVectors(yvecs, props, obj.mrimgs);
            
            % plot main figure components
            figure('Units', 'pixels', 'Position', ...
                [props.offsetFromEdge props.offsetFromEdge ...
                props.pixelSize props.pixelSize]);
            hold on;
            sumrr = 0;
            for r = 1:length(props.regressionRequests)
                sumrr = sumrr + props.regressionRequests{r};
            end
            regressed      = cell(1, sumrr);
            scattered      = cell(1, length(xvecs));
            handlesRegress = zeros(  sumrr, 1);
            i1 = 1;
            for i = 1:length(xvecs)
                incr         = (max(xvecs{i}) - min(xvecs{i}))/length(xvecs{i});
                xspan        =                  min(xvecs{i}):incr:max(xvecs{i});
                
                %  Unique to Bland-Altman
                difference           =  yvecs{i} - xvecs{i};
                average              = (yvecs{i} + xvecs{i})/2;
                regressed{i}.meany   = mean(difference);
                regressed{i}.stdy    = std( difference);
                regressed{i}.confidy = 1.96*regressed{i}.stdy;
                onesy                = ones(length(xspan), 1);
                scattered{i}         = plot(average, difference, props.markers{i});
                set(scattered{i}, 'MarkerSize',          props.markerArea{i}, ...
                    'MarkerEdgeColor',     props.markerColors{i});
                if (props.regressionRequests{i})
                    [cfun gof fitout]     = fit(xvecs{i}, yvecs{i}, 'poly1');
                    regressed{i1}.cfun    = cfun;
                    regressed{i1}.gof     = gof;
                    regressed{i1}.fitout  = fitout;
                    regressed{i1}.pi      = predint(cfun, xspan, ...
                        props.confidenceInterval, 'functional', 'on');
                    regressed{i1}.fittedy = cfun.p1*xspan + cfun.p2;
                    handlesRegress(i1) = ...
                        plot(xspan,      regressed{i}.meany*onesy, ...
                        props.regressLines{i}, ...
                        'LineWidth', props.regressLineWidths{i}, ...
                        'Color',     props.lineColors{i});
                    plot(xspan,     (regressed{i}.meany - regressed{i}.confidy)*onesy, ...
                        props.confidenceLines{i}, ...
                        'LineWidth', props.confidenceLineWidths{i}, ...
                        'Color',     props.lineColors{i});
                    plot(xspan,     (regressed{i}.meany + regressed{i}.confidy)*onesy, ...
                        props.confidenceLines{i}, ...
                        'LineWidth', props.confidenceLineWidths{i}, ...
                        'Color',     props.lineColors{i});
                    i1 = i1 + 1;
                end
            end
            import mlpublish.*;
            
            % diaries
            ScatterPublisher.diaryRegressions(regressed, props, 'plotBlandAltman');
            if (props.globalRegression)
                ScatterPublisher.plotGlobalBlandAltmanRegression(obj);
            end
            ScatterPublisher.refinePlotForPublication(props, handlesRegress);
            ScatterPublisher.printFigure(gcf, props);
            hold off;
        end % static function plotBloandAltman
    end % static methods
    
    methods      
        
        function   obj = ScatterPublisher(props)
            
            %% SCATTERPUBLISHER CTOR
            %  Usage:  obj = mlfourd.ScatterPublisher(props)
            %          props:  PublishProperties class containing specifiers for display & printing
            %  See also:  mlpublish.PublishProperties
            %  To do:     set access to protected to encourage use of factory design patterns
            %
            switch (nargin)
                case 0    % required by Matlab
                    obj.props = mlpublish.PublishProperties;
                case 1
                    assert(isstruct(props) || isa(props, 'mlpublish.PublishProperties'), ...
                        'mlpublish.TypeErr:unrecognizedType', ...
                        ['type of props was not recognized: ' class(props)]);
                    %%props.checkSelf; 
                    obj.props = props;
                otherwise
                    error('mlpublish:InputParamsErr:NumberOfParamsUnsupported', ...
                        ['mlpublish.ScatterPublisher.ctor does not support ' ...
                        num2str(nargin) ' passed params.']);
            end
        end % ctor
    end % methods
>>>>>>> .merge-right.r251
end
