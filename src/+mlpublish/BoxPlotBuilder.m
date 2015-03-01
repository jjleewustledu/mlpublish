classdef BoxPlotBuilder  
	%% BOXPLOTBUILDER ... 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.73043 (R2014a) 
 	%  $Id$ 
 	 

	properties (Dependent)
        length
    end
    
    properties
        oefRatio
        thickness
    end 
    
    methods %% GET
        function l = get.length(this)
            assert(length(this.oefRatio) == length(this.thickness));
            l = length(this.oefRatio);
        end
    end

	methods 
        function writeCorticalThicknessFigure3(this)
            low = []; high = []; grouping = ones(this.length, 1);
            for t = 1:this.length
                if (this.oefRatio(t) > 1.13)
                    high = [high this.thickness(t)]; %#ok<*AGROW>
                    grouping(t) = 2;
                else
                    low  = [low  this.thickness(t)];
                end
            end
            
            fprintf('mean(oef ratio <= 1.1) = %f; mean(oef ratio > 1.13 = %f;\n', ...
                     mean(low), mean(high));
            fprintf('median(oef ratio <= 1.1) = %f; median(oef ratio > 1.13 = %f;\n', ...
                     median(low), median(high));
            fprintf('N(oef ratio <= 1.13) = %f; N(oef ratio > 1.13) = %f;\n', ...
                     length(low), length(high));
            [h,p,ci,stats] = ttest2(low, high, 'Vartype', 'unequal');
            assert(length(ci) == 2);
            fprintf('hypothesis test result:  %i; p-value:  %g; confidence interval: [%g %g];\n', ...
                     h, p, ci(1), ci(2))
            disp(stats)
            boxplot(this.thickness, grouping, ...
                   'labels',    {'normal OEF ratio' 'increased OEF ratio'}, ...
                   'colors',     [0 0 0], ...
                   'outliersize', 12, ...
                   'notch',      'on', ...
                   'symbol',     'sk')
        end
        
 		function this = BoxPlotBuilder(varargin) 
 			%% BOXPLOTBUILDER 
 			%  ... 

            p = inputParser;
            addRequired(p, 'OefRatio',  @(x) isnumeric(x));
            addRequired(p, 'Thickness', @(x) isnumeric(x));            
            parse(p, varargin{:});
            
            this.oefRatio  = p.Results.OefRatio;
            this.thickness = p.Results.Thickness;
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

