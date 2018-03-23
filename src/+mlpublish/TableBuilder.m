classdef TableBuilder  
	%% TABLEBUILDER ... 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.73043 (R2014a) 
 	%  $Id$ 
 	 

	properties          
         oefRatio % against mean(oef_cerebellar)
         oefRatioStd % stddev from approx. 75 sampled parcellations per hemisphere
         studyPath
         thickness
         thicknessStd
         exclusions
    end 
    
    properties (Dependent)
        length
    end

    methods %% GET
        function len = get.length(this)
            len = length(this.oefRatio);
        end
    end
    
	methods 
 		 
 		function writeTable1(this) 
            for t = 1:2:this.length
                fprintf('% 4.2f (%4.2f) \t % 4.2f (%4.2f) % 4.2f (%4.2f) \t % 4.2f (%4.2f) \n', ...
                        this.thickness(t),   this.thicknessStd(t), ...
                        this.oefRatio(t),    this.oefRatioStd(t), ...
                        this.thickness(t+1), this.thicknessStd(t+1), ...
                        this.oefRatio(t+1),  this.oefRatioStd(t+1));
            end
        end 
        
        function writeFigure3(this)
            
            this = this.applyExclusions(this.exclusions);
            low = []; high = []; grouping = ones(this.length, 1);
            
            for t = 1:this.length
                if (this.oefRatio(t) > 1.13)
                    high = [high this.thickness(t)]; %#ok<*AGROW>
                    grouping(t) = 2;
                else
                    low  = [low  this.thickness(t)];
                end
            end
            
            fprintf('mean(oef ratio <= 1.1) = %f; mean(oef ratio > 1.1 = %f;\n', mean(low), mean(high));
            fprintf('median(oef ratio <= 1.1) = %f; median(oef ratio > 1.1 = %f;\n', median(low), median(high));
            fprintf('N(oef ratio <= 1.1) = %f; N(oef ratio > 1.1) = %f;\n', length(low), length(high));
            [h,p,ci,stats] = ttest2(low, high, 'Vartype', 'unequal');
            assert(length(ci) == 2);
            fprintf('hypothesis test result:  %i; p-value:  %g; confidence interval: [%g %g];\n', h, p, ci(1), ci(2))
            disp(stats)
            boxplot(this.thickness, grouping, ...
                   'labels', {'normal OEF ratio' 'increased OEF ratio'}, ...
                   'colors', [0 0 0], ...
                   'outliersize', 12, ...
                   'notch', 'on', ...
                   'symbol', 'sk')
        end
        
 		function this = TableBuilder(varargin) 
 			%% TABLEBUILDER 
 			%  ... 

            p = inputParser;
            addOptional(p, 'StudyPath', pwd, @isdir);
            parse(p, varargin{:});
            
            this.studyPath = p.Results.StudyPath;
            load(fullfile(this.studyPath, 'matlab_2017oct19_2113.mat'));
           
            this.oefRatio     = ds.oefRatio;
            this.oefRatioStd  = ds_std.oefRatio;
            this.thickness    = ds.thicknessAbsolute;
            this.thicknessStd = ds_std.thicknessAbsolute;
            this.exclusions   = exclusions2;
            
            assert(length(this.oefRatio)  == length(this.thickness));
            assert(length(this.oefRatio)  == length(this.oefRatioStd));
            assert(length(this.thickness) == length(this.thicknessStd));
        end 
        
        function this = applyExclusions(this, exclusions)            
            this.oefRatio     = this.oefRatio(    ~exclusions);
            this.oefRatioStd  = this.oefRatioStd( ~exclusions);
            this.thickness    = this.thickness(   ~exclusions);
            this.thicknessStd = this.thicknessStd(~exclusions);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

