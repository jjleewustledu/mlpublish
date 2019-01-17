classdef BlandAltmanProperties < mlpublish.PublishProperties
    
    %% BLANDALTMANPROPERTIES is a registry of objects and data useful for creating Bland-Altman plots.
    %
    %  Instantiation:  bap = mlpublish.BlandAltmanProperties(filestem, title, nums)
    %                                                        ^         ^ strings
    %                                                                         ^ # of series
    %
    %  Created by John Lee on 2009-04-02.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %
    properties
        baXLabel = '';
        baYLabel = '';
    end
    
    methods
        
        function self = BlandAltmanProperties(varargin)
            
            %% BLANDALTMANPROPERTIES CTOR  
            %  Usage:  bap = mlpublish.BlandAltmanProperties(filestem, title, nums)
            %                                                ^         ^ strings
            %                                                                 ^ # of series
            %
            self = self@mlpublish.PublishProperties(varargin{:}); 
            switch (nargin)
                case 0 % required by OOMatlab
                case 1
                    assert(ischar(self.filestemEps)); 
                    self.filestemEps = [filestem '_BA'];
                case 2
                    assert(ischar(self.filestemEps)); 
                    assert(ischar(self.aTitle));
                    self.filestemEps = [self.filestemEps '_BA'];
                    self.aTitle          = [self.aTitle ' Bland-Altman'];
                case 3
                    assert(ischar(self.filestemEps)); 
                    assert(ischar(self.aTitle)); 
                    assert(isnumeric(self.numSeries));
                    self.filestemEps = [self.filestemEps '_BA'];
                    self.aTitle          = [self.aTitle ' Bland-Altman'];
                    self.numSeries       =  self.numSeries;
                otherwise
                    throw(MException( ...
                        'InputParamsErr:TooManyParams', ...
                       ['BlandAltmanProperties.ctor does not support ' num2str(nargin) ' input params']));
            end
        end % ctor
        
        function xl = get.baXLabel(self)
            
            xDescription = strtrim([self.xCorrection ' ' upper([self.xModality ' ' self.xMetric])]);
            yDescription = strtrim([self.yCorrection ' ' upper([self.yModality ' ' self.yMetric])]);            
            xl           = ['Mean' texlabel('\{  ') self.fsymb(xDescription) ', ' ...
                                                  self.fsymb(yDescription) texlabel('  \}')];
        end
        
        function yl = get.baYLabel(self)
            
            xDescription = strtrim([self.xCorrection ' ' upper([self.xModality ' ' self.xMetric])]);
            yDescription = strtrim([self.yCorrection ' ' upper([self.yModality ' ' self.yMetric])]);
            yl           = [self.fsymb(yDescription) ' - ' self.fsymb(xDescription)];
        end
    end % methods
end
