
% Test_DataPublisher < mlunit.test_case tests high-level functioning of 
% the DataPublisher class.
%
% Instantiation:
%         runner = mlunit.text_test_runner(1, 2);
%         loader = mlunit.test_loader;
%         run(runner, load_tests_from_test_case(loader, 'mlpublish.Test_DataPublisher'));
%         run(gui_test_runner, 'mlpublish.Test_DataPublisher');
%         run(gui_test_runner, 'mlpublish.Test_DataPublisher');
%
% See Also:
%         help text_test_runner
%         http://mlunit.dohmke.de/Main_Page
%         http://mlunit.dohmke.de/Unit_Testing_With_MATLAB
%         thomi@users.sourceforge.net
%
% Created by John Lee on 2008-11 -21.
% Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
% Report bugs to <bug.perfusion.neuroimage.wustl.edu@gmail.com>.

classdef Test_DataPublisher < mlunit.test_case
     
     properties
          pubData = [];
     end
 
     methods

          %  CTOR  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          function obj = Test_DataPublisher(varargin)
               obj = obj@mlunit.test_case(varargin{:});
               obj.pubData = mlpublish.DataPublisher.makeDefaultPrintProps;
          end

          function obj = test_makeData(obj)
               data = mlpublish.DataPublisher.makeData % static factory
               mlunit.assert(isstruct(data));
          end
          
          function obj = test_makeData(obj)
               rnds = random('Normal', 0, 1, 2, 4);
               xvecs{1} = [ 20 40 60 80 100 ]';
               xvecs{2} = [ 10*rand 10*rand 10*rand 10*rand 10*rand ]';
               xvecs{3} = [ 121 122 123 124 125 ]';
               yvecs{1} = [ 2 4 6 8 10 ]';
               yvecs{2} = [ rand rand rand rand rand ]';
               yvecs{3} = [ 1 4 9 16 25 ]';
               sp = mlpublish.DataPublisher.makeData(xvecs, yvecs, obj.pubData)
               mlunit.assert(length(sp) > 0)
          end
     end
end