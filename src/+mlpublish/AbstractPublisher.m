classdef AbstractPublisher 
	%% ABSTRACTPUBLISHER establishes an interface for classes useful for preparing for publication 
	%  Version $Revision$ was created $Date$ by $Author$  
 	%  and checked into svn repository $URL$ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract)
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        publishProps
 	end 

	methods 

 		function this = AbstractPublisher(props) 
 			%% ABSTRACTPUBLISHER (ctor) 
 			%  Usage:  this = this@mlpublish.AbstractPublisher([props]);
            %                                                   ^ PublishProperties object
            if (isa('props', 'mlpublish.PublishProperties'))
                this.publishProps = props;
            end
 		end % AbstractPublisher (ctor) 
 	end 

	methods (Abstract)
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
    end 
    
    methods (Static)
        
        function   fgnii1 = makeFg(fgnii, datnii, datnii1)
        
            %% MAKEFG_NOZEROS modifies a foreground mask so that only nonzero voxels in datanii or
            %                 datanii1 are returned.   Foreground probabilities are not made binary.
            %
            %  Usage:  fgnii1 = mlpublish.ScatterPublisher.makeFg(fgnii, datanii [, datanii1])
            %                                                     ^      ^ NIfTI 
            %
            if (iscell(fgnii));     fgnii =   fgnii{1}; end
            if (iscell(datnii));   datnii =  datnii{1}; end
            if (iscell(datnii1)); datnii1 = datnii1{1}; end
            %%disp(['# fg voxels -> ' num2str(sum(dip_image(fgnii.img) > 0))]);
            no0data = ones(datnii.size);
            no0data = no0data     .* mostOfImg(datnii.img);
            if (nargin > 2)
                no0data = no0data .* mostOfImg(datnii1.img);
            end
            fgnii1  = fgnii.makeSimilar(fgnii.img .* no0data, 'ScatterPublisher.makeFg');
                  
            function most = mostOfImg(img)
                
                %% MOSTOFIMG returns a binary mask of img > threshold,
                %            with threshold = remainder(mean(img)/std(img))
                %  See also:  rem
                %
                dipimg    = dip_image(img);
                meanimg   =   mean(dipimg);
                stdimg    =    std(dipimg);
                remainder =   rem(meanimg, stdimg); % remainder:  meanimg - n*stdimg, n = fix(meanimg./stdimg)
                most      =   double(dipimg > remainder);
                %%disp(['# voxels > remainder -> ' num2str(sum(dipimg > remainder))]);
            end
            
            function gt = gtEps(img)
                
                %% GTEPS returns a binary mask of img > eps; not sufficient for makeFg
                %  See also:  rem
                %
                gt = double(dip_image(img) > eps);
                disp(['# voxels > eps -> ' num2str(sum(dip_image(img) > eps))]);
            end
        end % static fg
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
