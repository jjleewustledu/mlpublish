classdef ImagePublisher 
    %% ImagePublisher prepares image-slices for publication.
    %
    %  Instantiation:    obj = mlpublish.ImagePublisher()
    %
    %                    floc: mlfourd.FourdLocator object of the image on the filesystem
    %
    %  Created by John Lee on 2008-07-08.
    %  Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <bug.perfusion.neuroimage.wustl.edu@gmail.com>.
    
    properties (Constant)
    end
    
    properties 
        floc_         = '';
        niiCells_     = {[]};
		slice_        = 5;
        cmap_         = [];
		cmap_name_    = 'bone';
        brighten_value_  = 0;
        cbar_         = true;
		cbarpos_      = 'East';
		cbartextpos_  = [8 8];
		cbartextpos2_ = [8 138]; %[8 225]
		cbarfontsize_ = 14; % 20;
		zoom_         = 200;   % percent
		dpi_          = 300;   % dots per inch for printing
        hshow_        = 0;     % figure handle from imshow
        ok2print_     = true;
        driver_       = '-depsc2'; % '-dtiff';
        img_ext_      = '.eps';    % '.tif';
        options_      = '-painters';   % '-painters -opengl -cmyk '
        range_        = [];
        interpreter_  = 'none'; % 'latex', which requires $...$, \[...\], etc., 'tex', 'none'
    end
    
    methods

        function obj = ImagePublisher(niiCells)
            if (nargin > 0)
                obj.niiCells_ = niiCells;
            end
        end
    end
    
    methods (Static)

        function obj = publishImgsCoeffVar(niiCells, sl, cmap, cbar, zoom)
            %%  PUBLISHIMGSCOEFFVAR is a static factory method
            %   Usage:  obj = publishImgsCoeffVar(niiCells, sl, colormap, colorbar, zoom)
            %
            %			niiCells -> cell array of NIfTI
            %           sl       -> int slice to publish (optional)
            %           colormap ->	string				 (optional)
            %           colorbar ->	bool				 (optional)
            %			zoom     -> 					 (optional)
			import mlpublish.*
			for i = 1:length(niiCells.images)
					niiCells{i}.meanDipImage =      mean(niiCells{i}.img);
					unity                    = ones(size(niiCells{i}.img));
					niiCells{i}.img          =           niiCells{i}.img/niiCells{i}.meanDipImage - unity;	
			end
			obj = publishImgs(niiCells, sl, cmap, cbar, zoom);
        end
        
        function caught = testRegex(str, regex)
            caught = regexpi(str, regex, 'once', 'match');
        end
        
        function niiCells = globNiiDir(dirargs, lbl_regex)
            
            %% GLOBNIIDIR
            %  Usage:  niiCells = globNiiDir(dirargs, lbl_regex)
            %                                         ^ string 
            %  E.g.:   nc = ImagePublisher.globNiiDir('BIP_LocalAIF_MrRec_*.4dfp.nii.gz', ...
            %                                         '(?<=BIP_LocalAIF_(MrRec|Mr)_)\w*(?=\.4dfp)')
            if (nargin < 2); lbl_regex = '(?<=BIP_LocalAIF_Mr_)\w*(?=\.4dfp)'; end
            dirlist = dir(dirargs);
            niiCells = cell(length(dirlist),1);
            for d = 1:length(dirlist)
                name                  = dirlist(d).name;
                try                    
                    niiCells{d}       = mlfourd.NIfTI.load(name);
                    niiCells{d}.label = regexpi(name, lbl_regex, 'once', 'match');
                    fprintf(1, '%g -> %s\n',d, niiCells{d}.label);
                catch ME
                    warning('mlpublish:ImagePublisher:globNiiDir', ...
                       ['could not make label from ' name ...
                        ' using regex ' lbl_regex]);
                    disp(ME);
                end
            end
        end % static getDirlist
        
        function obj = publishImg(nii, sl, bright, rng, ok2print)
            import mlpublish.*;
            switch (nargin)
                case 1
                    obj = ImagePublisher.publishImgs({nii});
                case 2
                    obj = ImagePublisher.publishImgs({nii}, sl);
                case 3
                    obj = ImagePublisher.publishImgs({nii}, sl, 'bone', bright);
                case 4
                    obj = ImagePublisher.publishImgs({nii}, sl, 'bone', bright, rng);
                case 5
                    obj = ImagePublisher.publishImgs({nii}, sl, 'bone', bright, rng, ok2print);
                otherwise
                    paramError(?ImagePublisher, 'nargin', nargin);
            end
        end
        
        function [n,xout] = histImg(nii, sl)
            img = nii.img(:,:,sl);
            img  = mlfourd.NiiBrowser.makeSampleVoxels(img, img > eps);
            [n,xout] = hist(img, 32);
            figure('Color', 'white');
            bar(xout,n);
            title(nii.label);
        end
        
        function obj = publishImgs(niiCells, sl, cmap, bright, range, ok2print)
            %% PUBLISHIMGS is a static factory method
            %  Usage:   obj = publishImgs(niiCells, sl, colormap, colorbar, zoom)
            %			niiCells -> image-data object specified by makeImgData
            %           sl       -> int slice to publish (optional)
            %           cmap     ->	string				 (optional)
            %           bright   ->	[-1..1]				 (optional)
            import mlpublish.*
            obj = ImagePublisher;
            props = PublishProperties;
            switch (nargin)
				case 1
                    obj.niiCells_   = niiCells;
                case 2
                    obj.niiCells_   = niiCells;
					obj.slice_      = sl;
                case 3
                    obj.niiCells_   = niiCells;
					obj.slice_      = sl;
					obj.cmap_name_  = cmap;
				case 4
                    obj.niiCells_        = niiCells;
					obj.slice_           = sl;
					obj.cmap_name_       = cmap;
					obj.brighten_value_  = bright;
                case 5
                    obj.niiCells_       = niiCells;
                    obj.slice_          = sl;
					obj.cmap_name_      = cmap;
					obj.brighten_value_ = bright;
                    obj.range_          = range;
                case 6
                    obj.niiCells_       = niiCells;
					obj.slice_          = sl;
					obj.cmap_name_      = cmap;
					obj.brighten_value_ = bright;
                    obj.range_          = range;
                    obj.ok2print_       = ok2print;
                otherwise
                    paramError(?ImagePublisher, nargin, 'nargin');
            end
            if (obj.zoom_ < 1)
				obj.zoom_ = obj.zoom_ * 100; 
            end 
            
            for i = 1:length(obj.niiCells_)
 				figure(...
					'Units', 'pixels', ...
					'Color', 'Black', ...
					'PaperPositionMode', 'auto');
                hold on;
                set(gca, ...
                    'FontName', props.gcaFontName, ...
                    'FontSize', props.gcaFontSize, ...
                    'Box', 'off', ...
                    'TickDir', 'in', ...
                    'TickLength', [props.tickLength, props.tickLength], ...
                    'XMinorTick', 'off', ...
                    'YMinorTick', 'off', ...
                    'XColor', 'black', ...
                    'YColor', 'black', ...
                    'LineWidth', 1);
                obj.cmap_ = colormap(obj.cmap_name_);
                imgvec  = mlfourd.NiiBrowser.makeSampleVoxels(...
                    obj.niiCells_{i}.img(:,:,obj.slice_), abs(obj.niiCells_{i}.img(:,:,obj.slice_)) > eps);
                meanimg = mean(imgvec);
                modeimg = mode(imgvec);
                stdimg  = std( imgvec);
                maximg  = max( imgvec);
                minimg  = min( imgvec);
                if (modeimg/meanimg < 0.618)
                    centerimg = modeimg;
                    centertype = 'mode';
                else
                    centerimg = meanimg;
                    centertype = 'mean';
                end
                if (any(strfind(lower(obj.niiCells_{i}.label), 'probmodel')) || ...
                    any(strfind(lower(obj.niiCells_{i}.label), 'beta'))      || ...
                    any(strfind(lower(obj.niiCells_{i}.label), 'gamma')))
                    obj.range_ = [];
                    obj.cmap_ = brighten(obj.cmap_, obj.brighten_value_);
                else
                    if (stdimg > centerimg)
                        obj.range_ = [max(minimg, 0) min(2*centerimg, maximg)];
                    else
                        obj.range_ = [max(minimg, centerimg - 2*stdimg) min(centerimg + 2*stdimg, maximg)];
                    end
                    %brighten(-centerimg/maximg);
                end       
                if (exist('range', 'var')); obj.range_ = range; end
                if (exist('bright', 'var')); obj.brighten_value_ = bright; end
                obj.cmap_ = brighten(obj.cmap_, obj.brighten_value_);
				obj.hshow_ = obj.niiCells_{i}.imshow(obj.slice_, ...
                        'Colormap', obj.cmap_, ...
						'InitialMagnification', obj.zoom_, ...
						'DisplayRange', obj.range_);
                if (obj.cbar_)
                    colorbar(   'location', 'east', ...
                                'XColor',   'White', ...
                                'YColor',   'White', ...
                                'Units',    'pixels', ...
                                'TickDir',  'in', ...
                                'FontName', 'Lucida Console', ...
                                'FontSize',  obj.cbarfontsize_);
                    text(obj.cbartextpos2_(1), obj.cbartextpos2_(2), obj.niiCells_{i}.label, ...
                                'Color',    'White', ...
                                'FontName', 'Lucida Console', ....
                                'FontSize', obj.cbarfontsize_, ...
                                'FontWeight', 'normal', ...
                                'Interpreter', obj.interpreter_, ...
                                'Rotation', 0);    
                end
                %axis square;
                hold off;
                
                fprintf(1, '%i \t %s \t center (%s): %g std: %g min: %g max: %g\n', ...
                    i, obj.niiCells_{i}.label, centertype, centerimg, stdimg, minimg, maximg);
				fname = ['ImagePublisher_' obj.niiCells_{i}.fileprefix];
                if (~isempty(fname) && obj.ok2print_)
					disp(['Printing figure ' num2str(gcf) ' with driver ' obj.driver_ ...
                          ' using options ' obj.options_ ' and resolution ' num2str(obj.dpi_) ' dpi to ' ...
                          pwd '/' fname obj.img_ext_]);
                    set(gcf, 'InvertHardCopy', 'off');
					print(gcf, obj.driver_, ...
                               obj.options_, ['-r' num2str(obj.dpi_)], [fname obj.img_ext_]);  %#ok<*MCPRT>
                end
            end % for i
            
        end % static publishImgs
        
        function str = niisLabels(niiCells)
            obj.niiCells_   = niiCells;
            str = '';
            for i = 1:length(niiCells)
                str = [str sprintf('%i -> %s\n', i, obj.niiCells_{i}.label)]; %#ok<AGROW>
            end
            fprintf(1, '%s', str);
        end
        
    end % methods (Static)
    
end % classdef
    
    
