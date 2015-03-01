classdef NP797 
	%% NP797 manages special cases for Tim Carroll and the Northwestern study of 2007-2010
	%  
	%% Version $Revision$ was created $Date$ by $Author$  
 	%% and checked into svn repository $URL$ 
 	%% Developed on Matlab 7.10.0.499 (R2010a) 
 	%% $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    properties
        currentPid
        npreg
        deprecated
    end
    
    properties (Dependent)
        pnumPath
    end
    
	methods 

 		function this = NP797(pnum) 
 			%% NP797 (ctor) 
 			%  Usage:  obj = NP797(pnum)
            this.currentPid = pnum;
            this.npreg      = mlfsl.Np797Registry.instance;
            this.deprecated = mlfsl.DeprecatedImagingFeatures.instance;
 		end  
        
        function idx1  = listIndex(this, pnum)
            if (nargin < 2 && ~isempty(this.currentPid)); pnum = this.currentPid; end
            idx1    = -1;
            for idx = 1:this.npreg.lenPnumNp797 %#ok<FORFLG>
                if (strcmp(this.npreg.getPnumNp797(idx), pnum)) %#ok<PFBNS>
                    idx1 = idx; %#ok<PFTUS>
                    break;
                end
            end
        end
        
        function [epi, cbfPixdim] = getNiftiInfo(this, pnum, rank)
            import mlfourd.*;
            if (nargin < 3); rank = 3; end
            if (nargin < 2 && ~isempty(this.currentPid)); pnum = this.currentPid; end
            epi       = NIfTI.load(this.epi_filename(pnum));
            epd       = epi.pixdim; 
            assert(rank <= numel(epd));
            cbfPixdim = epd(1:rank);
        end
 	end 

	methods (Static)
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed)
        
        function [epi, cbf, cbf2] = getEpiPair(pnum, flips, returnNii)
            %% SHOWEPIPAIR 
            %  [epi, jess] = showEpiPair(pnum, returnNii)
            %                                 ^ return NIfTIs, else dip_images
            import mlfourd.*;
            import mlpublish.*;
            if (nargin < 3); returnNii = false; end
            if (nargin < 2); flips = 'yyt'; end
            obj     = mlpublish.NP797(pnum);
            loaded  = load(obj.deprecated.jessy_filename(pnum), 'image_names');
            names   = loaded.image_names;
            loaded  = load(obj.deprecated.jessy_filename(pnum), 'images');
            imgs    = loaded.images;
            assert(~isempty(names)); assert(~isempty(imgs));
            cbfIdx  = strmatch('qCBF_nSVD', names);
            [epi, cbfPixdim] = obj.getNiftiInfo(pnum, NP797.rank(imgs{cbfIdx}));
            cbf     = NIfTI(imgs{cbfIdx}, names{cbfIdx}, ...
                    ['NIfTI from EPI and ' obj.deprecated.jessy_filename(pnum, false)], cbfPixdim);
            cbf2    = {[]};
            if (~returnNii)
                epi  = dip_image(epi.img);
                cbf  = dip_image(cbf.img);
                cbf2 = flip4d(cbf, flips);
            end
        end        
        
        function flipAndWrite(pnum, flips)
            %% FLIPANDWRITE
            %  [sta, std] = flipAndWrite(pnum, flips)
            %                                 ^ per flip4d
            import mlfourd.*;
            import mlpublish.*;
            assert(1 == exist('flips', 'var'));
            obj              = mlpublish.NP797(pnum);
            loaded           = load(obj.deprecated.jessy_filename(pnum), 'image_names');
            names            = loaded.image_names;
            loaded           = load(obj.deprecated.jessy_filename(pnum), 'images');
            imgs             = loaded.images;
            assert(~isempty(names)); assert(~isempty(imgs));
            wd               = cd(obj.qcbf_path(pnum));
            disp(['NP797.flipAndWrite:  working in ' wd]);
            assert(numel(names) == numel(imgs));
            for i = 1:numel(names)
                [~, cbfPixdim] = obj.getNiftiInfo(pnum, NP797.rank(imgs{i}));
                nii            = NIfTI(imgs{i}, names{i}, ...
                               ['NIfTI from EPI and ' obj.deprecated.jessy_filename(pnum, false)], cbfPixdim);
                dimg           = dip_image(nii.img);
                nii.img        = double(flip4d(dimg, flips));
                nii.save;
            end
        end
        
        function r = rank(img)
            r = numel(size(img));
        end
 	end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
