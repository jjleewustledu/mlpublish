
% Test_ImagePublisher < mlunit.test_case  tests high-level functioning of the ImagePublisher class.
%
% Instantiation:
%         runner = mlunit.text_test_runner(1, 2);
%         loader = mlunit.test_loader;
%         run(runner, load_tests_from_test_case(loader, 'mlpublish.Test_ImagePublisher'));
%         run(gui_test_runner, 'mlpublish.Test_ImagePublisher');
%         run(gui_test_runner, 'mlpublish.Test_ImagePublisher');
%
% See Also:
%         help text_test_runner
%         http://mlunit.dohmke.de/Main_Page
%         http://mlunit.dohmke.de/Unit_Testing_With_MATLAB
%         thomi@users.sourceforge.net
%
% Created by John Lee on 2008-12-16.
% Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
% Report bugs to <bug.perfusion.neuroimage.wustl.edu@gmail.com>.

classdef Test_ImagePublisher < mlunit.test_case
     
	properties
		imgDat = struct([]);
		sl     = 0;
		cmap   = 'jet';
		cbar   = [];
		zoom   = 100;
	end

	methods

		%  CTOR  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		function obj = Test_ImagePublisher(varargin)
			obj = obj@mlunit.test_case(varargin{:});
			obj.imgDat = makeImgData('vc4405', 'cbf');
		end

		function obj = test_publishImgs(obj)

		end
	end
end