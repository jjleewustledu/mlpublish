classdef PublishProperties
    
    %% PUBLISHPROPERTIES is a registry of objects and data useful for creating figures for publication.
    %
    %  Instantiation:  pp = mlpublish.PublishProperties(filestem, title, nums)
    %                                                   ^         ^ strings
    %                                                                    ^ # of series
    %
    %  Created by John Lee on 2009-04-02.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email="bug.jjlee.wustl.edu@gmail.com"/>.
    %
    properties	
        
		filestemEps          = '';
        aTitle               = '';
        blocking        = false;
		rescale              = 'none'; % options:  'none', 'to_mean', 'std_moment'
		xModality            = 'MR';
		xMetric              = '';
        xCorrection          = '';
        xDescription         = '';
        anXLabel             = '';
		yModality            = 'MR';
		yMetric              = '';
        yCorrection          = '';
        yDescription         = '';
        aYLabel              = '';
        markers              = {};
		markerArea           = {};
		markerColors         = {};
		legendLabels         = {'grey' 'white'};        
		legendLocation       = 'NorthEast';
        regressionRequests   = {};
        lineWidths           = {};
        regressLines         = {};
		confidenceLines      = {};
		regressLineWidths    = {};
		confidenceLineWidths = {};
        libmodel             = 'poly1';
        
        % DEPRECATED
        scatter              = true;
        BlandAltman          = false
        switches             = [1 1];
        globalRegression     = false;
        
        % low-level properties
        anXLim               = [];
        aYLim                = [];
        minColor             =  0.05;  % Magn. Res. Med. publication quidelines
        monocolor            = [0.618/2 0.618/2 0.618];
        colorscheme          = 'grey'; % 'rgb', 'grey', 'mono'
		lineColors           = {}; 
        axesColor            =  [0.05 0.05 0.05];
		% add lineStyles to add lines
		%%lineStyles         = {'-'};
        maxFontSize          = 16;
        legendFontSize       = 14;
		gcaFontName          = 'Lucida Console';
		gcaFontSize          = 14;
		axesFontName         = 'Lucida Console';
		axesFontSize         = 14;
		titleFontName        = 'Lucida Console';
		titleFontSize        = 14;        	
		pixelSize            = 600;
		offsetFromEdge       = 100;
		dpi                  = 200; % 1200 Magn. Res. Med. publication guidelines		
		tickLength           = 0.02;
		confidenceInterval   = 0.95;
        numSeries            = 2;
    end % properties
    
    properties (Access = 'protected') % default values
        markers_              = {'.' '.'};
		markerArea_           =  9;
		legendLabels_         = {'grey' 'white'};        
		legendLocation_       = 'NorthEast';
        regressionRequests_   =  true;
        lineWidths_           =  1;
        regressLines_         = 'k -';
		confidenceLines_      = {'k--' 'k:'};
		regressLineWidths_    =  2;
		confidenceLineWidths_ =  1;
		lineColors_           = [0.05 0.05 0.05]; 
        db                    =  0;
        mimaging
        pimaging
		% include lineStyles_ to add lines
		%%lineStyles_         = {'-'};
    end % private properties

    methods

        function self = PublishProperties(filestem, atitle, nums)
            
            %% PUBLISHPROPERTIES CTOR  
            %  Usage:  pp = mlpublish.PublishProperties(filestem, title, nums)
            %                                           ^         ^ strings
            %                                                            ^ # of series
            %
            import mlpublish.* mlfsl.*;
            switch (nargin)
                case 0 % required by OOMatlab; use property initializations
                    %self.filestemEps = ['PublishProperties_ctor_' datestr(now,30)];
                case 1
                    assert(ischar(filestem)); 
                    self.filestemEps = filestem;
                case 2
                    assert(ischar(filestem)); assert(ischar(atitle));
                    self.filestemEps = filestem;
                    self.aTitle      = atitle;
                case 3
                    assert(ischar(filestem)); assert(ischar(atitle)); assert(isnumeric(nums));
                    self.filestemEps = filestem;
                    self.aTitle      = atitle;
                    self.numSeries   = nums;
                otherwise
                    throw(MException( ...
                        'InputParamsErr:TooManyParams', ...
                       ['PublishProperties.ctor does not support ' num2str(nargin) ' input params']));
            end
            self.lineColors_     = [self.minColor self.minColor self.minColor];
            self.axesColor       = [self.minColor self.minColor self.minColor];
            self.legendFontSize  =  self.maxFontSize - 2;
            self.gcaFontSize     =  self.maxFontSize;
            self.axesFontSize    =  self.maxFontSize;
            self.titleFontSize   =  self.maxFontSize;
            self.db              =  Np797Registry.instance;
            self.pimaging        =  PETStudy;
            self.mimaging        =  MRStudy;
            
        end % ctor
        
        function s  = fsymb(self, descr)
            
            %% FSYMB returns a string-form:  f_{subscripts} (descr)
            %
            switch (self.rescale)
                case 'std_moment'
                    s = [texlabel('f_{mu, sigma} (') descr texlabel(')')];
                case 'to_mean'
                    s = [texlabel('f_{mu} (')        descr texlabel(')')];
                case 'none'
                    s = descr;
                otherwise
                    throw(MException( ...
                        'mlpublish:PassedParamOutOfBounds', ['rescale -> ' self.rescale]));
            end
        end
        
        function fs = get.legendFontSize(self)
            fs = self.maxFontSize - 2;
        end
        
        function fs = get.gcaFontSize(self)
            fs = self.maxFontSize;
        end
        
        function fs = get.axesFontSize(self)
            fs = self.maxFontSize;
        end
        
        function fs = get.titleFontSize(self)
            fs = self.maxFontSize;
        end        
        
        function xc = get.xCorrection(self)
            
            if (mlpet.O15Builder.BUTANOL_CORRECTION)
                xc = 'Perf.-Corr.';
            else
                xc = '';
            end
        end
        
        function xd = get.xDescription(self)
            
            if (isempty(self.xDescription))
                xd = [self.xCorrection ' ' upper([self.xModality ' ' self.xMetric])];
            else
                xd = self.xDescription;
            end
            xd     = strtrim(xd);
        end
        
        function yd = get.yDescription(self)
            
            if (isempty(self.yDescription))
                yd = [self.yCorrection ' ' upper([self.yModality ' ' self.yMetric])];
            else
                yd = self.yDescription;
            end
            yd     = strtrim(yd);
        end
        
        function xl = get.anXLabel(self)
            
            if (isa(self, 'BlandAltmanProperties'))
                xDescrip = [self.xCorrection ' ' upper([self.xModality ' ' self.xMetric])];
                yDescrip = [self.yCorrection ' ' upper([self.yModality ' ' self.yMetric])];
                xl           = ['Mean' texlabel('\{') self.fsymb(xDescrip) ', ' ...
                    self.fsymb(yDescrip) texlabel('\}')];
            else
                if (isempty(self.anXLabel))
                    if (strcmp('none', self.rescale))
                        units = mlpublish.PublishProperties.unitsOfMeasurement({self.xModality self.xMetric});
                        if (~isempty(units)); units = [' / ' units]; end
                    else
                        units = '';
                    end
                    xl = self.fsymb([self.xDescription units]);
                else
                    xl = self.anXLabel;
                end
            end
            xl         = strtrim(xl);
        end
        
        function yl = get.aYLabel(self)
            
            if (isa(self, 'BlandAltmanProperties'))
                xDescrip = [self.xCorrection ' ' upper([self.xModality ' ' self.xMetric])];
                yDescrip = [self.yCorrection ' ' upper([self.yModality ' ' self.yMetric])];
                yl       = [self.fsymb(yDescrip) ' - ' self.fsymb(xDescrip)];
            else
                if (isempty(self.aYLabel))
                    if (strcmp('none', self.rescale))
                        units = mlpublish.PublishProperties.unitsOfMeasurement({self.yModality self.yMetric});
                        if (~isempty(units)); units = [' / ' units]; end
                    else
                        units = '';
                    end
                    yl = self.fsymb([self.yDescription units]);
                else
                    yl = self.aYLabel;
                end
            end
            yl         = strtrim(yl);
        end
        
        function m  = get.markers(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.markers))
                self.markers = cell(1,self.numSeries);
                if (iscell(self.markers_))
                    self.markers = self.markers_;
                else
                    for i = 1:self.numSeries %#ok<*FORFLG,*PFUNK>
                        self.markers{i} = self.markers_;
                    end
                end
            end
            m = self.markers;
        end
        
        function ma = get.markerArea(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.markerArea))
                self.markerArea = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.markerArea{i} = self.markerArea_;
                end
            end
            ma = self.markerArea;
        end
        
        function mc = get.markerColors(self)
            
            % depends on self.monocolor & self.numSeries
            if (self.numSeries ~= length(self.markerColors))
                
                % re-build markerColors
                self.markerColors = cell(1,self.numSeries);
                switch (self.colorscheme)
                    case 'grey'
                        for r = 1:self.numSeries
                            if (self.numSeries > 1)
                                self.markerColors{r} = mlpublish.PublishProperties.greyValue( ...
                                    (r - 1)/(self.numSeries - 1));
                            else
                                self.markerColors{r} = self.monocolor;
                            end
                        end
                    case 'rgb'
                        for r = 1:self.numSeries
                            if (self.numSeries > 1)
                                self.markerColors{r} = mlpublish.PublishProperties.rgbWarpedValue( ...
                                    (r - 1)/(self.numSeries - 1), self.numSeries, 1);
                            else
                                self.markerColors{r} = self.monocolor;
                            end
                        end
                    otherwise % 'mono'
                        for r = 1:self.numSeries
                            self.markerColors{r} = self.monocolor;
                        end
                end
            end
            mc = self.markerColors;
        end
        
		function ll = get.legendLabels(self)

            % depends on self.numSeries
            if (self.blocking); 
                for i = 1:length(self.legendLabels_)
                    self.legendLabels_{i} = ['block ' self.legendLabels_{i}]; 
                end
            end
            ll = self.legendLabels_;
        end        
        
        function rr = get.regressionRequests(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.regressionRequests))
                self.regressionRequests = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.regressionRequests{i} = self.regressionRequests_;
                end
            end
            rr = self.regressionRequests;
        end
        
        function lw = get.lineWidths(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.lineWidths))
                self.lineWidths = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.lineWidths{i} = self.lineWidths_;
                end
            end
            lw = self.lineWidths;
        end
        
        function rl = get.regressLines(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.regressLines))
                self.regressLines = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.regressLines{i} = self.regressLines_;
                end
            end
            rl = self.regressLines;
        end
        
        function cl = get.confidenceLines(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.confidenceLines))
                self.confidenceLines = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.confidenceLines{i} = self.confidenceLines_{i};
                end
            end
            cl = self.confidenceLines;
        end
        
        function lw = get.regressLineWidths(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.regressLineWidths))
                self.regressLineWidths = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.regressLineWidths{i} = self.regressLineWidths_;
                end
            end
            lw = self.regressLineWidths;
        end
        
        function lw = get.confidenceLineWidths(self)
            
            % depends on self.numSeries
            if (self.numSeries ~= length(self.confidenceLineWidths))
                self.confidenceLineWidths = cell(1,self.numSeries);
                for i = 1:self.numSeries
                    self.confidenceLineWidths{i} = self.confidenceLineWidths_;
                end
            end
            lw = self.confidenceLineWidths;
        end            
        
        function lc = get.lineColors(self)
            
            % depends on self.numSeries
			self.lineColors = cell(1, self.numSeries);
            if (1 == self.numSeries)
                self.lineColors{1} = self.monocolor;
            else
                switch (self.colorscheme)
                    case {'grey','rgb'}
                        for c = 1:self.numSeries
                            self.lineColors{c} = self.markerColors{c};
                        end
                    otherwise % mono
                        for c = 1:self.numSeries
                            self.lineColors{c} = [self.minColor self.minColor self.minColor];
                        end
                end
            end
            lc = self.lineColors;
        end

		function self = set.xMetric(self, metr)
            
            %% SET.XMETRIC
            %  metr:  metric or units of measurement
            %
			self.xMetric = mlpublish.PublishProperties.metricfind(metr);
		end
		
		function self = set.yMetric(self, metr)
            
            %% SET.YMETRIC
            %  metr:  metric or units of measurement
            %
			self.yMetric = mlpublish.PublishProperties.metricfind(metr);
        end
        
        function ok = checkSelf(self)
            
            %% CHECKSELF checks that all fields of the instantiated PublishProperties 
            %            are sensible.
            %
            %  Usage:  props = mlpublish.PublishProperties(...);
            %          if (props.checkSelf); disp('ok'); end
            %
            N  = self.numSeries;
            Ns = num2str(N);
            assert(ischar(self.filestemEps), ...
                'mlpublish:PropertyErr', ...
               ['property filestemEps is a ' class(self.filestemEps)]);
            assert(ischar(self.aTitle), ...
                'mlpublish:PropertyErr', ...
               ['property aTitle is a ' class(self.aTitle)] );
            assert(self.blocking || ~self.blocking);
            assert(strcmp(self.rescale, 'none')     || ...
                   strcmp(self.rescale, 'to_mean') || ...
                   strcmp(self.rescale, 'std_moment'), ...
                'mlpublish:PropertyErr', ...
               ['property rescale was ' self.rescale]);
            assert(~isempty(self.xModality), ...
                'mlpublish:PropertyErr', ...
                'property xModality is empty');
            assert(~isempty(self.xMetric), ...
                'mlpublish:PropertyErr', ...
                'property xMetric is empty');
            assert(ischar(self.xCorrection), ...
                'mlpublish:PropertyErr', ...
               ['property xCorrection is a ' class(self.xCorrection)]);
            assert(ischar(self.anXLabel), ...
                'mlpublish:PropertyErr', ...
               ['property anXLabel is a ' class(self.anXLabel)] );            
            assert(~isempty(self.yModality), ...
                'mlpublish:PropertyErr', ...
                'property yModality is empty');
            assert(~isempty(self.yMetric), ...
                'mlpublish:PropertyErr', ...
                'property yMetric is empty'); 
            assert(ischar(self.yCorrection), ...
                'mlpublish:PropertyErr', ...
               ['property yCorrection is a ' class(self.yCorrection)]);
            assert(ischar(self.aYLabel), ...
                'mlpublish:PropertyErr', ...
               ['property aYLabel is a ' class(self.aYLabel)] );
            assert(ischar(self.markers{N}), ...
                'mlpublish:PropertyErr', ...
               ['property markers {' Ns '}  is a ' class(self.markers{N})]);
            assert(self.markerArea{N} > 0, ...
                'mlpublish:PropertyErr', ...
               ['property markerArea {' Ns '} -> ' num2str(self.markerArea{N})]);
            assert(3 == length(self.markerColors{N}), ...
                'mlpublish:PropertyErr', ...
               ['property markerColors {' Ns '} is ' num2str(self.markerColors{N})]);           
            assert(ischar(self.legendLabels{N}), ...
                'mlpublish:PropertyErr', ...
               ['property legendLabels {' Ns '} is a ' class(self.legendLabels{N})]);
            assert(ischar(self.legendLocation), ...
                'mlpublish:PropertyErr', ...
               ['property legendLocation is a ' class(self.legendLocation)]);
            assert(self.regressionRequests{N} || ~self.regressionRequests{N});
            assert(self.lineWidths{N} > 0, ...
                'mlpublish:PropertyErr', ...
               ['property lineWidths{' Ns '} --> ' num2str(self.lineWidths{N})]);
            assert(ischar(self.regressLines{N}), ...
                'mlpublish:PropertyErr', ...
               ['property regressLines {' Ns '} is a ' class(self.regressLines{N})]);
            assert(ischar(self.confidenceLines{N}), ...
                'mlpublish:PropertyErr', ...
               ['property confidenceLines {' Ns '} is a ' class(self.confidenceLines{N})]);
            assert(isnumeric(self.regressLineWidths{N}), ...
                'mlpublish:PropertyErr', ...
               ['property regressLineWidths {' Ns '} is a ' class(self.regressLineWidths{N})]);
            assert(isnumeric(self.confidenceLineWidths{N}), ...
                'mlpublish:PropertyErr', ...
               ['property confidenceLineWidths {' Ns '} is a ' class(self.confidenceLineWidths{N})]);
            assert(isnumeric(self.minColor));
            assert(~isempty(self.lineColors{N}), ...
                'mlpublish:PropertyErr', ...
               ['property lineColors{' Ns '} --> ' num2str(self.lineColors{N})]);
            assert(3 == length(self.axesColor), ...
                'mlpublish:PropertyErr', ...
               ['property axesColor -> ' num2str(self.axesColor)] );
            assert(self.maxFontSize > 8, ...
                'mlpublish:PropertyErr', ...
               ['property maxFontSize is ' num2str(self.maxFontSize)]);            
            assert(self.legendFontSize <= self.maxFontSize, ...
                'mlpublish:PropertyErr', ...
               ['property legendFontSize is ' num2str(self.legendFontSize)]);  
            assert(ischar(self.gcaFontName), ...
                'mlpublish:PropertyErr', ...
               ['property gcaFontName is a ' class(self.gcaFontName)] );
            assert(self.gcaFontSize <= self.maxFontSize, ...
                'mlpublish:PropertyErr', ...
               ['property gcaFontSize -> ' num2str(self.gcaFontSize)]);
            assert(ischar(self.axesFontName), ...
                'mlpublish:PropertyErr', ...
               ['property axesFontName is a ' class(self.axesFontName)] );
            assert(self.axesFontSize <= self.maxFontSize, ...
                'mlpublish:PropertyErr', ...
               ['property axesFontSize -> ' num2str(self.axesFontSize)]);
            assert(ischar(self.titleFontName), ...
                'mlpublish:PropertyErr', ...
               ['property titleFontName is a ' class(self.titleFontName)] );
            assert(self.titleFontSize <= self.maxFontSize, ...
                'mlpublish:PropertyErr', ...
               ['property titleFontSize -> ' num2str(self.titleFontSize)]);
            assert(isnumeric(self.pixelSize));
            assert(isnumeric(self.offsetFromEdge));           
            assert(isnumeric(self.dpi), ...
                'mlpublish:PropertyErr', ...
               ['property dpi -> ' num2str(self.dpi)]);
            assert(self.tickLength > 0, ...
                'mlpublish:PropertyErr', ...
               ['property tickLength -> ' num2str(self.tickLength)]);
            assert(self.confidenceInterval < 1, ...
                'mlpublish:PropertyErr', ...
               ['property confidenceInterval -> ' num2str(self.confidenceInterval)]);
            assert(self.numSeries > 0, ...
                'mlpublish:PropertyErr', ...
               ['property numSeries -> ' num2str(self.numSeries)]);
            ok = true;
        end % funcion checkSelf
    end % methods
    
    methods (Static)
        
        function   m = metricfind(str)
            
            %% METRICFIND returns the first recognizable metric in the passed string
            %  Usage:     m = metricfind(str)
            %             ^ canonical string, e.g., 'cbf'
            %                            ^ long string
            %  See also:  strfind
            if (    numel(strfind(lower(str), 'oef'   )) > 0)
                m = 'OEF';
            elseif (numel(strfind(lower(str), 'cmro2' )) > 0)
                m = 'CMRO2';
            elseif (numel(strfind(lower(str), 'cbf'   )) > 0)
                m = 'CBF';
            elseif (numel(strfind(lower(str), 'cbv'   )) > 0)
                m = 'CBV';
            elseif (numel(strfind(lower(str), 'mtt'   )) > 0)
                m = 'MTT';
            elseif (numel(strfind(lower(str), 'counts')) > 0)
                m = 'Counts';
            else
                m = 'Unknown';
            end
        end % static function metricfind
        
        function gy  = greyValue(x)
            
            mingy = [0 0 0];
            maxgy = [0.618 0.618 0.618];
            gy    = mingy + x*(maxgy - mingy);
        end
        
        function rgb = rgbValue(x, gamma)
            
            %% RGBVALUE   
            %  Usage:  rgb = mlpublish.PublishProperties.rgbValue(x, gamma)
            %          x:      real number [0, 1] which will map to an RGB color
            %          gamma:  hwhm scale parameter for Cauchy distrib., default = 0.618/2
            %
            switch (nargin)
                case 0
                    throw(MException('mlpublish:TooFewPassedParameters', ['nargin -> ' num2str(nargin)]));
                case 1
                    rgb = mlpublish.PublishProperties.rgbWarpedValue(x, 2);
                case 2
                    rgb = mlpublish.PublishProperties.rgbWarpedValue(x, 2, gamma);
                otherwise
                    throw(MException('mlpublish:TooManyPassedParameters', ['nargin -> ' num2str(nargin)]));
            end
        end % static function rgbValue
        
        function rgb = rgbWarpedValue(x, N, gamma)
            
            %% RGBWARPEDVALUE   
            %  Usage:  rgb = mlpublish.PublishProperties.rgbWarpedValue(x [, N [, gamma]])
            %          rgb assigns a unit rgb-color for every x in a set of size N
            %          x:      real number [0, 1] which will map to an RGB color
            %          N:      number of colors,                       , default = 1
            %          gamma:  hwhm scale parameter for Cauchy distrib., default = 0.618/N
            %
            WINDOW = 0.5; % keep plotted objects dark on a white background
            switch (nargin)
                case 0
                    throw(MException('mlpublish:TooFewPassedParameters', ['nargin -> ' num2str(nargin)]));
                case 1
                    N     = 2;
                    gamma = 0.618/2;
                case 2
                    assert(N > 1);
                    gamma = 0.618/(N-1); % golden ratio = 0.618
                case 3                    
                otherwise
                    throw(MException('mlpublish:TooManyPassedParameters', ['nargin -> ' num2str(nargin)]));
            end
            assert(isnumeric(x)); assert(isnumeric(N)); assert(isnumeric(gamma));
            if (x < 0); x = abs(x);   end
            if (x > 1); x = mod(x,1); end
            import mlpublish.*;
            rgb = [ PublishProperties.cauchy(x - gamma, 0.5, gamma) ...
                    PublishProperties.cauchy(x,         0.5, gamma) ...
                    PublishProperties.cauchy(x + gamma, 0.5, gamma) ]; 
            rgb = WINDOW*rgb/max(rgb);
        end % static function rgbWarpedValue
        
        
        function rgbs  = rgbWarpedValues(N, gamma)
            
            %% RGBWARPEDVALUES return a cell-array of N rgb-colors
            %  Usage:     rgbs = mlpublish.PublishProperties.rgbWarpedValues(N [, gamma])
            %  See also:  rgbWarpedValue
            %
            if (nargin < 1); N = 1; end
            if (nargin < 2); gamma = 0.618/N; end
            rgbs = cell(N,1);
            for x = 1:N
                rgbs{x} = mlpublish.PublishProperties.rgbWarpedValue(x, N, gamma);
            end
        end % static function rbgWarpedValues
        
        function   y   = cauchy(x, x0, gam, int)
            
            %% CAUCHY maps x -> int gam^2/((x - x0)^2 + gam^2), amplitude = int
            %
            switch (nargin)
                case 0
                    throw(MException('mlpublish:TooFewPassedParameters', ['nargin -> ' num2str(nargin)]));
                case 1
                    x0 = 0; gam = 1; int = 1;
                case 2
                            gam = 1; int = 1;
                case 3
                                     int = 1;
                case 4
                otherwise
                    throw(MException('mlpublish:TooManyPassedParameters', ['nargin -> ' num2str(nargin)]));
            end
            y = int*gam^2/((x - x0)^2 + gam^2);
        end % static function cauchy
        
        function units = unitsOfMeasurement(tags)
            
            %% UNITSOFMEASUREMENT returns units of measurement for each of the data tags
            %  Usage:  units = mlpublish.PublishProperties.unitsOfMeasurement(tags)
            %          tags:   cell-array with strings for modality and measurement,
            %                  e. g., {'pet' 'cbf'}
            %
            import mlpublish.*;
            assert(iscell(tags));
            assert(~isempty(tags));
            for t = 1:length(tags)
                assert(ischar(tags{t}));
            end
            try
                units = makeUnits(tags);
            catch ME
                
                idSegLast = regexp(ME.identifier, '(?<=:)\w+$', 'match');
                if (strcmp(idSegLast, 'InternalDataErr'))
                    
                    try
                        % circular permutation of tags
                        tmp = tags{1};
                        for t = 1:length(tags)-1
                            tags{t} = tags{t+1};
                        end
                        tags{length(tags)} = tmp;
                        units = PublishProperties.makeUnits(tags);
                    catch ME1
                        ME1 = addCause(ME1, ME);
                        rethrow(ME1);
                    end
                end
            end
            
            function u = makeUnits(tags)
                
                %% MAKEUNITS is nested
                %
                switch (lower(tags{1}))
                    case {'pet', 'mr wm-scaled', 'mr bookends', 'pet oef'}
                        switch (lower(tags{2}))
                            case 'cbf'
                                u = '(mL/min/100 g)';
                            case 'cbv'
                                u = '(mL/100 g)';
                            case 'mtt'
                                u = 's';
                            case 'oef'
                                u = '';
                            case 'cmro2'
                                u = '--';
                            otherwise
                                throw(MException( ...
                                    'mlpublish:InternalDataErr', ...
                                    ['tags{2} -> ' tags{2} ' was unrecognizable']));
                        end
                    case {'mr mlem', 'mrmlem', 'mlem', 'mr svd', 'mrsvd', 'svd', 'mr'}
                        switch (lower(tags{2}))
                            case 'cbf'
                                u = 'Arbitrary';
                            case 'qcbf'
                                u = '(mL/min/100 g)';
                            case 'cbv'
                                u = 'Arbitrary';
                            case 'qcbv'
                                u = '(mL/100 g)';
                            case 'mtt'
                                u = 'Arbitrary';
                            case 'qmtt'
                                u = 's';
                            case 'oef'
                                u = '';
                            case 'adc'
                                u = '10^{-5} mm^2/s';
                            otherwise
                                throw(MException( ...
                                    'mlpublish:InternalDataErr', ...
                                    ['tags{2} -> ' tags{2} ' was unrecognizable']));
                        end
                    case {'mr laif' 'mrlaif' 'laif' 'mr oef'}
                        switch (lower(tags{2}))
                            case 'cbf'
                                u = 'Arbitrary';
                            case 'cbv'
                                u = 'Arbitrary';
                            case 'mtt'
                                u = 's';
                            case 'oef'
                                u = '';
                            otherwise
                                throw(MException( ...
                                    'mlpublish:InternalDataErr', ...
                                    ['tags{2} -> ' tags{2} ' was unrecognizable']));
                        end
                    otherwise
                        u = 'Unknown';
                        %throw(MException( ...
                        %    'mlpublish:InternalDataErr', ...
                        %    ['tags{1} -> ' tags{1} ' was unrecognizable']));
                end
            end
        end % static function unitsOfMeasurement
    end % methods
end
