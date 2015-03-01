classdef Publisher 
	%% PUBLISHER is an abstract class for creating figures for publication.
	%% Version $Revision$ was created $Date$ by $Author$  
	%% and checked into svn repository $URL$ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id$
    %  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) ...

	properties 
        % N.B. (Abstract, Access='private', GetAccess='protected', SetAccess='protected', ...
        %       Constant, Dependent, Hidden, Transient)
	end 

	methods 

		function this = Publisher() 
			%% PUBLISHER (ctor)  
			%  Usage:  obj = Publisher() 
			%                  ^ 
            %  N.B. superArgs{1} = ;
            %       this = this@SuperClass(superArgs{:});
		end %  Publisher ctor
    end 
    
    methods
        % N.B. (Static, Abstract, Access='', Hidden, Sealed)
    end
    % Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
