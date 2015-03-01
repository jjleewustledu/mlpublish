% MultipatientPublisher generates figures suitable for publication for single patients.
% Factory design pattern.
%
% Instantiation:    obj = MultipatientPublisher.publishAll(pnum)
%
%                   pnum: patient ID
%
% Created by John Lee on 2008-06-16.
% Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
% Report bugs to <bug.perfusion.neuroimage.wustl.edu@gmail.com>.

classdef MultipatientPublisher 
     
     properties (SetAccess = 'private')
     end
     
     properties
          npnum                    = '';
          processBlocks            = true;
          processImages            = true;
          processMultiScatter      = true;
          processBlandAltman       = true;
          publishedBlocksPET       = [];
          publishedBlocksMR1       = [];
          publisehdBlocksMR0       = [];
          publishedImagesPET       = [];
          publishedImagesMR1       = [];
          publishedImagesMR0       = [];
          publishedMultiScatterMR1 = [];
          publishedMultiScatterMR0 = [];
          publishedBlandAltmanMR1  = [];
          publishedBlandAltmanMR0  = [];
          pubProps                 = [];
          NPIDs                    = 1;
          xVec                     = [];
          yVec                     = [];
          y2Vec                    = [];
     end
     
     methods (Static)  %  FACTORY METHODS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          function [xvec yvec zvec] = collateCells(xvecs, yvecs, zvecs)
               
               for i = 1:length(xvecs)
                    assert(length(xvecs{i}) == length(yvecs{i}) && length(yvecs{i}) == length(zvecs{i}), ...
                    ['mlpublish.MultipatientPublisher.collateCells found inconsistent vectors: ' ...
                     '\n\tlength(xvecs{' num2str(i) '}) -> ' length(xvecs{i}) ...
                     '\n\tlength(yvecs{' num2str(i) '}) -> ' length(yvecs{i}) ... ...
                     '\n\tlength(zvecs{' num2str(i) '}) -> ' length(zvecs{i})]);
               end
               
               fulllen = 0;
               for i = 1:length(xvecs)
                    fulllen = fulllen + length(xvecs{i});
               end               
               xvec = zeros(fulllen, 1);
               yvec = zeros(fulllen, 1);
               zvec = zeros(fulllen, 1);
               
               accum = 0;
               for j = 1:length(xvecs)                    
                    xvec(accum+1:accum+length(xvecs{j})) = xvecs{j};
                    yvec(accum+1:accum+length(yvecs{j})) = yvecs{j};
                    zvec(accum+1:accum+length(zvecs{j})) = zvecs{j};
                    accum = accum + length(xvecs{j});
               end
          end
          
          % publishAll generates all supported figures for the specified patient.
          %
          % Usage: obj = publishAll(pnum)
          %
          %         pnum:    patient ID
          %         obj:    class instantiation
          %
          % Examples: 
          %         obj = MultipatientPublisher.publishAll('vc4903')
          %
          % Created by John Lee on 2008-06-17.

          function obj = publishAll(sid, metric)

               assert(isa(sid,'char'), ...
                      'NIL:MultipatientPublisher.publishAll:TypeErr:unrecognizedType', ...
                      ['type of sid was unexpected: ' class(sid)]);
               switch (nargin)
                    case 1
                         metric = 'CBF';
                    case 2
                         assert(isa(metric,'char'), ...
                             'NIL:MultipatientPublisher.publishAll:TypeErr:unrecognizedType', ...
                             ['type of sid was unexpected: ' class(metric)]);
                    otherwise
                         error('NIL:MultipatientPublisher.publishAll:ctor:PassedParamsErr:numberOfParamsUnsupported', ...
                               help('publishAll'));
               end
               obj        = MultipatientPublisher(sid);
               
               xIdx  = 1;
               yIdx  = 2;
               y2Idx = 3;
               
               for p = 1:obj.NPIDs
                    
                    pnum = pnumList(p);
                    
                    imgData    = makeImgData(pnum, metric);
                    masks      = false;
                    sliceRange = [0 imgData.sizes3d(3)-1];

                    Unity      = dip_image(ones(imgData.sizes3d));
                    UnitSlice  = dip_image(ones(imgData.sizes3d(1),imgData.sizes3d(2)));
                    Zero       = newim(imgData.sizes3d);
                    sliceBlock = Zero;

                    for s = sliceRange(1):sliceRange(2)
                      if (s == slice1(pnum) || s == slice2(pnum))
                          sliceBlock(:,:,s) = UnitSlice; end
                    end
                    if islogical(masks),
                        masks = get7Rois(pnum); 
                    end

                    masks.fg = masks.fg & sliceBlock;
                    tissue   = masks.fg & (masks.grey | masks.white | masks.basalganglia);

                    %  MAKE BLOCK IMAGES FOR EVERY p  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    binSizes = [db('binlength', obj.npnum) db('binlength', obj.npnum) 1];
                    binUnity = binVoxels(Unity, binSizes);
                    binParen = binVoxels(tissue, binSizes);

                    xImage                 = imgData.images{xIdx};
                    xImage.mmppix          = imgData.images{xIdx}.mmppix .* binSizes;
                    xImage.pnum             = imgData.pnum; % kludge
                    [xVec{p} xImage.dipImage] = lpeekVoxels_gen(...
                       binVoxels(xImage.dipImage, binSizes), xImage, ...
                       binUnity, ...
                       binParen);

                    yImage                 = imgData.images{yIdx};  
                    yImage.mmppix          = imgData.images{yIdx}.mmppix .* binSizes;
                    yImage.pnum             = imgData.pnum; % kludge
                    [yVec{p} yImage.dipImage] = lpeekVoxels_gen(...
                       binVoxels(yImage.dipImage, binSizes), yImage, ...
                       binUnity, ...
                       binParen);

                    y2Image                 = imgData.images{y2Idx};  
                    y2Image.mmppix          = imgData.images{y2Idx}.mmppix .* binSizes;
                    y2Image.pnum             = imgData.pnum; % kludge
                    [y2Vec{p} y2Image.dipImage] = lpeekVoxels_gen(...
                       binVoxels(y2Image.dipImage, binSizes), y2Image, ...
                       binUnity, ...
                       binParen);

                    assert(length(xVec{p}) == length(yVec{p}), ...
                       'NIL:mlpublish.MultipatientPublisher.publishAll:ArraySizeMismatch', ...
                       ['length(xVec{' ensurePid(p) '}) ~= length(yVec{' ensurePid(p) '})']);
                    assert(length(xVec{p}) == length(y2Vec{p}), ...
                       'NIL:mlpublish.MultipatientPublisher.publishAll:ArraySizeMismatch', ...
                       ['length(xVec{' ensurePid(p) '}) ~= length(y2Vec{' ensurePid(p) '})']);
               end
               
               sumLens = 0;
               for p = 1:NPIDs
                    sumLens = sumLens + length(xVec{p})
               end
               xVecs  = double(sumLens, 1);
               yVecs  = double(sumLens, 1);
               y2Vecs = double(sumLens, 1);
               xVecs( 1:length(xVec{1} )) = xVec{1};
               yVecs( 1:length(yVec{1} )) = yVec{1};
               y2Vecs(1:length(y2Vec{1})) = y2Vec{1};
               lastIdx = length(xVec{1});
               for p = 2:NPIDs
                    xVecs( lastIdx+1:lastIdx+length(xVec{p} )) = xVec{p};
                    yVecs( lastIdx+1:lastIdx+length(yVec{p} )) = yVec{p};
                    y2Vecs(lastIdx+1:lastIdx+length(y2Vec{p})) = y2Vec{p};
                    lastIdx = lastIdx + length(xVec{p});
               end
               
               %  SCATTER FIGURES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
               finalBlur = db('mrblur', obj.npnum);
               finalBlur = finalBlur(1);
               cd(['/mnt/hgfs/' obj.npnum '/Figures']);
               
               if (obj.processMultiScatter)
                   obj.publishedMultiScatterMR1 = obj.publishScatter(...
                       xVecs, yVecs, ...
                       [imgData.images{yIdx}.imageName     ' / '  imgData.images{yIdx}.units ''], ...
                       [imgData.images{xIdx}.imageName     ' vs ' imgData.images{yIdx }.imageName     ' 4-scatter ' num2str(finalBlur) ' mm'], ...
                       [imgData.images{xIdx}.imageSafeName ' vs ' imgData.images{yIdx }.imageSafeName ' 4-scatter ' num2str(finalBlur) ' mm'], ...
                       obj.pubProps)
                   obj.publishedMultiScatterMR0 = obj.publishScatter(...
                       xVecs, y2Vecs, ...
                       [imgData.images{y2Idx}.imageName    ' / '  imgData.images{y2Idx}.units ''],  ...
                       [imgData.images{xIdx}.imageName     ' vs ' imgData.images{y2Idx}.imageName     ' 4-scatter ' num2str(finalBlur) ' mm'], ...
                       [imgData.images{xIdx}.imageSafeName ' vs ' imgData.images{y2Idx}.imageSafeName ' 4-scatter ' num2str(finalBlur) ' mm'], ...
                       obj.pubProps)
               end
               
               %  BLAND-ALTMAN FIGURES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               if (obj.processBlandAltman)
                   obj.publishedBlandAltmanMR1 = publishBlandAltman(...
                       xVecs, yVecs, ...
                       ['mean\{' imgData.images{yIdx}.imageName ', ' imgData.images{xIdx}.imageName '\} / (' imgData.images{xIdx}.units ')'], ...
                       ['(' imgData.images{yIdx}.imageName ' - ' imgData.images{xIdx}.imageName ') / (' imgData.images{xIdx}.units ')'],...
                       [imgData.images{yIdx}.imageName     ' Bland-Altman ' num2str(finalBlur) 'mm'], ... ...
                       [imgData.images{yIdx}.imageSafeName ' Bland-Altman ' num2str(finalBlur) 'mm'], ...
                       obj.pubProps)
                   obj.publishedBlandAltmanMR0 = publishBlandAltman(...
                       xVecs, yVecs, ...
                       ['mean\{' imgData.images{y2Idx}.imageName ', ' imgData.images{xIdx}.imageName '\} / (' imgData.images{xIdx}.units ')'], ...
                       ['(' imgData.images{y2Idx}.imageName ' - ' imgData.images{xIdx}.imageName ') / (' imgData.images{xIdx}.units ')'],...
                       [imgData.images{y2Idx}.imageName     ' Bland-Altman ' num2str(finalBlur) 'mm'], ... ...
                       [imgData.images{y2Idx}.imageSafeName ' Bland-Altman ' num2str(finalBlur) 'mm'], ...
                       obj.pubProps)
               end
          end
          
          % publishScatter plots scatter correlation analyses and prints to postscript.
          %
          % Usage: [obj] = publishScatter(obj, xVec, yVec, a_ylabel, a_title, plotname, plotProps)
          %
          %         xVec:    double column vector of reference values
          %         obj:   instance of the MultipatientPublisher class
          %
          % Examples: 
          %         aMultipatientPublisher = MultipatientPublisher(...);
          %         [obj] = aMultipatientPublisher.publishScatter(obj, obj)
          %
          % Created by John Lee on 2008-06-25.

          function [obj] = publishScatter(obj, xVec, yVec, a_ylabel, a_title, plotname, plotProps)

               switch (nargin)
                    case 2
                         assert(isa(obj,'MultipatientPublisher'), ...
                                'NIL:MultipatientPublisher.publishScatter:TypeErr:unrecognizedType', ...
                                ['type of obj was unexpected: ' class(obj)]);
                         assert(isa(xVec,'double'), ...
                                'NIL:MultipatientPublisher.publishScatter:TypeErr:unrecognizedType', ...
                                ['type of xVec was unexpected: ' class(xVec)]);
                           assert(isa(yVec,'double'), ...
                                  'NIL:MultipatientPublisher.publishScatter:TypeErr:unrecognizedType', ...
                                  ['type of yVec was unexpected: ' class(yVec)]);
                    otherwise
                         error('NIL:MultipatientPublisher.publishScatter:PassedParamsErr:numberOfParamsUnsupported', ...
                               help('mlpublish.MultipatientPublisher.publishScatter'));
               end
               
               MARKER_AREA    = 8;
               DPI            = 1200;
               PIXEL_SIZE     = 500;
               GREY_COLOR     = [0 0 0];
               PRINT_EPS      = 1;

               petImageName = 'PET H_2[^{15}O] CBF';
               petUnits     = 'mL/min/100 g';

               figure('Units', 'pixels', 'Position', [100 100 PIXEL_SIZE PIXEL_SIZE]);
               hold on;
               scatterGrey   = scatter(xVec, yVec);

               [voxels.cfun  voxels.gof  voxels.fitout]            = fit(xVec,     yVec,     'poly1');
               voxels.xspan  = 5:5:max(xVec)-5;
               voxels.pi     = predint(voxels.cfun,     voxels.xspan, 0.95, 'functional', 'on');
               voxels.fitted =         voxels.cfun.p1 * voxels.xspan + voxels.cfun.p2;
               plot(voxels.xspan, voxels.fitted, 'k -', 'LineWidth', 0.5); 
               plot(voxels.xspan, voxels.pi,     'k--', 'LineWidth', 0.5);

               %set(gca, 'ColorOrder', COLOR_ORDER);
               set(scatterGrey,     'Marker', '.');
               set(scatterGrey,     'SizeData', MARKER_AREA, 'MarkerEdgeColor', GREY_COLOR);

               htitle  = title(a_title);
               hxlabel = xlabel(['Permeability-Corrected ' petImageName ' / (' petUnits ')']);
               hylabel = ylabel(a_ylabel);

               set(gca, ...
                   'FontName', 'Helvetica', ...
                   'Box', 'off', ...
                   'TickDir', 'out', ...
                   'TickLength', [.02, .02], ...
                   'XMinorTick', 'on', ...
                   'YMinorTick', 'on', ...
                   'XColor', [.3 .3 .3], ...
                   'YColor', [.3 .3 .3], ...
                   'LineWidth', 1);
               set([htitle, hxlabel, hylabel], 'FontName','AvantGarde');
               set(gca,     'FontSize', 9);
               %%% set(hlegend, 'FontSize', 8);
               set([hxlabel, hylabel, htitle], 'FontSize', 12);

               set(gcf, ...
                   'Color', 'white', ...
                   'PaperPositionMode', 'auto');
               axis square;
               hold off;

               datReturn.voxels           = voxels;
               datReturn.xVec     = xVec;
               datReturn.yVec      = yVec; 
               datReturn.MARKER_AREA    = MARKER_AREA;
               datReturn.DPI            = DPI;
               datReturn.PIXEL_SIZE     = PIXEL_SIZE;
               datReturn.GREY_COLOR     = GREY_COLOR;
               datReturn.PRINT_EPS      = PRINT_EPS;

               if (PRINT_EPS & numel(plotname) > 0)
                   print(gcf, '-depsc2', '-cmyk', ['-r' num2str(DPI)], [plotname '.eps']); 
                   diary([plotname '.txt']);

                   disp([a_ylabel ' : GREY MATTER']);
                   datReturn.voxels.cfun
                   datReturn.voxels.gof
                   datReturn.voxels.fitout

                   diary off;
               end               
          end
          
          % publishBlandAltmaan plots Bland-Altman graphical analyses and prints to postscript.
          %
          % Usage: [obj] = publishBlandAltmaan(obj, xVec, yVec, a_xlabel, a_ylabel, a_title, plotname, plotProps)
          %
          %         xVec:    double column vector of reference values
          %         yVec:     double column vector of alternative values
          %         a_xlabel:
          %         a_ylabel:
          %         a_title:
          %         plotname:
          %         metricmax:
          %         plotProps:
          %         obj:   the instance of the MultipatientPublisher class
          %
          % Examples: 
          %         aMultipatientPublisher = MultipatientPublisher(...);
          %         [obj] = aMultipatientPublisher.publishBlandAltmaan(obj, ...)
          %
          % Created by John Lee on 2008-06-25.

          function [obj] = publishBlandAltmaan(obj, xVec, yVec, a_xlabel, a_ylabel, a_title, plotname, plotProps)

               switch (nargin)
                    case 2
                         assert(isa(obj,'MultipatientPublisher'), ...
                                'NIL:MultipatientPublisher.publishBlandAltmaan:TypeErr:unrecognizedType', ...
                                ['type of obj was unexpected: ' class(obj)]);
                         assert(isa(xVec,'double'), ...
                                'NIL:MultipatientPublisher.publishBlandAltmaan:TypeErr:unrecognizedType', ...
                                ['type of xVec was unexpected: ' class(xVec)]);
                         assert(isa(yVec,'double'), ...
                              'NIL:MultipatientPublisher.publishBlandAltmaan:TypeErr:unrecognizedType', ...
                              ['type of yVec was unexpected: ' class(yVec)]);
                    otherwise
                         error('NIL:MultipatientPublisher.publishBlandAltmaan:PassedParamsErr:numberOfParamsUnsupported', ...
                               help('publishBlandAltmaan'));
               end
               
               % WORKING CONSTANTS

               MARKER_AREA  = 16;
               DPI          = 1200;
               PIXEL_SIZE   = 500;
               MARKER_COLOR = [0 0 0];
               PRINT_EPS    = 1;
               NXSPAN       = 100;

               % PREALLOCATIONS

               if (length(xVec) ~= length(yVec))
                   error(['multipatient_voxels_blandaltman:  oops, length(xVec) -> ' ...
                          num2str(length(xVec)) ' but length(yVec) -> ' num2str(length(yVec))]); 
               end
               nVoxels = length(xVec);
               voxels  = struct( ...
                            'xVec',       newim(size(xVec)), ...
                            'yVec',       newim(size(yVec)), ...
                            'cfun',       cfit(fittype('poly1'), 0, 0),...
                            'gof',        struct('sse', 0, 'rsquare', 0, 'dfe', 0, 'adjrsquare', 0, 'rmse', 0), ...
                            'fitout',     struct('numobs', 0, 'numparam', 2, ...
                                             'residuals', zeros(nVoxels,1), 'Jacobians', zeros(nVoxels,2), ...
                                             'exitflag', 0, 'algorithm', 'QR factorization and solve', ...
                                             'iterations', 0), ...
                            'xspan',      zeros(1,NXSPAN), ...
                            'pi',         zeros(NXSPAN,2), ...
                            'fitted',     zeros(1,NXSPAN), ...
                            'regres_vec', zeros(nVoxels,1), ...
                            'diff_vec',   zeros(nVoxels,1), ...
                            'mean_vec',   zeros(nVoxels,1));

               % REGRESSING   

               [voxels.cfun  voxels.gof  voxels.fitout] = fit(xVec, yVec, 'poly1');
               voxels.xspan  = 5:5:max(xVec)-5;
               voxels.pi     = predint(voxels.cfun, voxels.xspan, 0.95, 'functional', 'on');
               voxels.fitted = voxels.cfun.p1* voxels.xspan  + voxels.cfun.p2;

               % CALCULATE BLAND-ALTMAN VALUES

               voxels.regres_vec = (yVec    - voxels.cfun.p2    )/voxels.cfun.p1;
               voxels.diff_vec   = (voxels.regres_vec  - xVec );
               voxels.mean_vec   = (voxels.regres_vec  + xVec )/2;

               voxels.meany = mean(voxels.diff_vec);
               voxels.stdy  = std(voxels.diff_vec);
               voxels.onesy = ones(size(voxels.xspan,2),1);

               % MAKE PLOTS

               plotMarginFrac = (100 + plotProps.plotMarginPercent)/100;
               xmin           =  0;
               xmax           =  plotMarginFrac * max(xVec);
               ymin           = -plotMarginFrac * max(yVec);
               ymax           =  plotMarginFrac * max(yVec);
               figure('Units', 'pixels', 'Position', [100 100 PIXEL_SIZE PIXEL_SIZE]);
               hold on;
               scatterGrey  = scatter(voxels.mean_vec,  voxels.diff_vec);
               plot(voxels.xspan,     voxels.meany*voxels.onesy, 'k -', 'LineWidth', 0.5);
               plot(voxels.xspan,  -2*voxels.stdy *voxels.onesy, 'k --', 'LineWidth', 0.5);
               plot(voxels.xspan,   2*voxels.stdy *voxels.onesy, 'k --', 'LineWidth', 0.5);    

               % CONFIGURE PLOTS

               set(scatterGrey,  'Marker', '.');   
               set(scatterGrey,  'SizeData', MARKER_AREA, 'MarkerEdgeColor', MARKER_COLOR);

               htitle  = title(a_title);
               hxlabel = xlabel(a_xlabel);
               hylabel = ylabel(a_ylabel);

               set(gca, ...
                   'FontName', 'Helvetica', ...
                   'Box', 'off', ...
                   'TickDir', 'out', ...
                   'TickLength', [.02, .02], ...
                   'XMinorTick', 'on', ...
                   'YMinorTick', 'on', ...
                   'XColor', [.3 .3 .3], ...
                   'YColor', [.3 .3 .3], ...
                   'LineWidth', 1);
               set([htitle, hxlabel, hylabel], 'FontName','AvantGarde');
               set(gca,     'FontSize', 9);
               %%% set(hlegend, 'FontSize', 8);
               set([hxlabel, hylabel, htitle], 'FontSize', 12);

               set(gcf, ...
                   'Color', 'white', ...
                   'PaperPositionMode', 'auto');
               xlim([xmin xmax]);
               ylim([ymin ymax]);
               axis square;
               hold off;

               % ASSIGN DATA TO RETURN

               datReturn.voxels        = voxels;
               datReturn.MARKER_AREA = MARKER_AREA;
               datReturn.DPI         = DPI;
               datReturn.PIXEL_SIZE  = PIXEL_SIZE;
               datReturn.MARKER_COLOR  = MARKER_COLOR;
               datReturn.PRINT_EPS   = PRINT_EPS;

               datReturn.xmin        = xmin;
               datReturn.xmax        = xmax;
               datReturn.ymin        = ymin;
               datReturn.ymax        = ymax;

               % PRINT DATA

               if (PRINT_EPS && numel(plotname) > 0)
                   print(gcf, '-depsc2', '-cmyk', ['-r' num2str(DPI)], [plotname '.eps']); 
                   diary([plotname '.txt']);

                   disp([a_ylabel ' : GREY MATTER']);
                   datReturn.voxels.cfun
                   datReturn.voxels.gof
                   datReturn.voxels.fitout
                   datReturn.voxels.meany
                   datReturn.voxels.stdy

                   diary off;
               end
          end
     end
     
     methods (Access = 'private') %  CTORS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          function obj = MultipatientPublisher(sid)
     
               switch (nargin)
                    case 0
                    case 1
                         assert(isa(sid,'char'), ...
                                'NIL:MultipatientPublisher:ctor:TypeErr:unrecognizedType', ...
                                ['type of sid was unexpected: ' class(sid)]);
                    otherwise
                         error('NIL:MultipatientPublisher:ctor:PassedParamsErr:numberOfParamsUnsupported', ...
                               help('MultipatientPublisher'));
               end
               obj.npnum = sid;
               
               obj.pubProps.markerArea          = 8;
               obj.pubProps.dpi                 = 1200; % Magn. Res. Med. publication guidelines
               obj.pubProps.pixelSize           = 500;
               obj.pubProps.aGca.fontName       = 'Helvetica';
               obj.pubProps.aGca.fontSize       = 12;
               obj.pubProps.aTitle.fontName     = 'AvantGarde';
               obj.pubProps.aTitle.fontSize     = 12;
               obj.pubProps.aLabel.fontName     = 'AvantGarde';
               obj.pubProps.aLabel.fontSize     = 12;
               obj.pubProps.aLegend.fontName    = 'AvantGarde';
               obj.pubProps.aLegend.fontSize    = 10;
               obj.pubProps.tissLine1           = 'k -';
               obj.pubProps.tissLine2           = 'k--';
               obj.pubProps.colors.tissue       = [ 0  0  0];
               obj.pubProps.colors.grey         = [ 0  0  0];
               obj.pubProps.colors.white        = [ 0  0  0];
               obj.pubProps.colors.basalganglia = [ 0  0  0];
               obj.pubProps.colors.arteries     = [ 1 .1  0];
               obj.pubProps.colors.csf          = [ 0 .4  1];
               obj.pubProps.printEps            = 1;
               
               obj.xVec                         = cell(obj.NPIDs);
               obj.yVec                         = cell(obj.NPIDs);
               obj.y2Vec                        = cell(obj.NPIDs);
          end
     end
end
