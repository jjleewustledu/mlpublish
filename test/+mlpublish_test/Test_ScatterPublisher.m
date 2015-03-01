
% Test_ScatterPublisher < mlunit.test_case  tests high-level functioning of the ScatterPublisher class.
%
% Instantiation:
%         runner = mlunit.text_test_runner(1, 2);
%         loader = mlunit.test_loader;
%         run(runner, load_tests_from_test_case(loader, 'mlpublish_test.Test_ScatterPublisher'))
%
%         run(mlunit.gui_test_runner, 'mlpublish_test.Test_ScatterPublisher');
%
% See Also:
%         help mlunit.text_test_runner
%         help mlunit.gui_test_runner
%         http://mlunit.dohmke.de/Main_Page
%         http://mlunit.dohmke.de/Unit_Testing_With_MATLAB
%         thomi@users.sourceforge.net
%
% Created by John Lee on 2008-6-30.
% Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
% Report bugs to <bug.perfusion.neuroimage.wustl.edu@gmail.com>.

classdef Test_ScatterPublisher < mlunit.test_case
    
    properties
        props    = [];     
        petnii   = struct([]);
        mr0nii   = struct([]);
        mr1nii   = struct([]);
        parnii   = struct([]);
        dbase    = 0;
        torun    = [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ];
    end
        
    methods
                            
        function obj = test_makeScatterCells(obj)
            if (~obj.torun(1)); return; end;
            e        = randn([1,5])/10;
            fiveones =  [ 1  1  1  1  1 ];
            xvecs{1} = ([ 2 4 6 8 10 ] + e)';
            xvecs{2} = (fiveones + fiveones*10.*e)';
            xvecs{3} = ([ 11 12 13 14 15 ] + e)';            
            e        = randn([1,5])/10;
            yvecs{1} = ([ 2 5 6 7 10 ] + e)';
            yvecs{2} = (fiveones + fiveones*20.*e)';
            yvecs{3} = ([ 1 4 9 16 25 ] + e)';            
            props                    = mlpublish.ScatterPublisher.makePrintProps;
            props.switches           = [ 1       1       1];
            props.legendLabels       = {'set1'  'set2'  'set3'};
            props.markers            = {'x'     'o'     's'};
            props.regressionRequests = { 1       1       1};
            props.markerColors       = {[0 0 1] [0 1 0] [1 0 0]};
            props.markerArea         = { 16      16      16};
            mlpublish.ScatterPublisher.makeScatterFromCells(xvecs, yvecs, props)
        end
        
        function obj = test_makeScatterVec(obj)
            if (~obj.torun(2)); return; end;
            x = [ -.4 -.3 -.2 -.1  0 .1  .2  .3  .4  .5  1.0  2.8 ]';
            y = [  .5  .4  .3  .2 .1  0 -.1 -.2 -.3 -.4 -1.1 -3.1 ]';            
            props = mlpublish.ScatterPublisher.makePrintProps;
            props.legendLabels       = {'set4'  };
            props.markers            = {'*'     };
            props.regressionRequests = { 1      };
            props.markerColors       = {[0 0 .5]};
            props.markerArea         = {16      };
            mlpublish.ScatterPublisher.makeScatterFromVecs(x, y, props);
        end
        
        function obj = test_makeScatterNiis(obj)
            if (~obj.torun(3)); return; end;
            import mlfourd.*;
            import mlpublish.*;
            disp('please inspect native images..........');
            obj = obj.prep_nii;
            dip_image(obj.petnii.img)
            dip_image(obj.mr0nii.img)
            dip_image(obj.parnii.img)
            disp('please inspect scatter..........');
            ScatterPublisher.makeScatterFromNiis({obj.petnii}, {obj.mr0nii}, {obj.parnii}, obj.props)
        end
        
        function obj = test_makeScatterNii(obj)
            if (~obj.torun(4)); return; end;   
            import mlfourd.*;
            import mlpublish.*;
            disp('please inspect native images..........');
            obj = obj.prep_nii;
            dip_image(obj.petnii.img)
            dip_image(obj.mr0nii.img)
            dip_image(obj.parnii.img)
            disp('please inspect scatter..........');
            mlpublish.ScatterPublisher.makeScatterFromNii(obj.petnii, obj.mr0nii, obj.parnii, obj.props)
        end
        
        function obj = test_makeScatterNoMask(obj)

            if (~obj.torun(5)); return; end;            
            import mlfourd.*;
            import mlpublish.*;
            petnii  = PETconverter.PETfactory(obj.dbase.pid, 'cbf'); 
            mr0nii  = load_nii(obj.dbase.mr0_filename('cbf'));
            parnii  = load_nii(obj.dbase.parenchyma_filename);
            onesnii = NiiBrowser.make_ones_nii_like(parnii);            
            props1  = ScatterPublisher.makePrintProps;
            disp('please inspect scatter..........');
            ScatterPublisher.makeScatterFromNii(petnii, mr0nii, onesnii, props1)
        end
        
        function obj = test_makeScatterNoDataZeros(obj)
            
            if (~obj.torun(6)); return; end;
            import mlfourd.*;
            import mlpublish.*;
            petnii = PETconverter.PETfactory(obj.dbase.pid, 'cbf'); 
            mr0nii = load_nii(obj.dbase.mr0_filename('cbf'));
            parnii = ScatterPublisher.makeFg_noDataZeros( ...
                     load_nii(obj.dbase.parenchyma_filename), {petnii}, {mr0nii})  
            props1 = ScatterPublisher.makePrintProps;
            disp('please inspect scatter..........');
            mlpublish.ScatterPublisher.makeScatterFromNii(petnii, mr0nii, parnii, props1)
        end
        
        function obj = test_makeScatterRescaleToMean(obj)
            
            if (~obj.torun(7)); return; end;
            import mlfourd.*;
            import mlpublish.*;
            petnii = PETconverter.PETfactory(obj.dbase.pid, 'cbf'); 
            mr0nii = load_nii(obj.dbase.mr0_filename('cbf'));
            parnii = ScatterPublisher.makeFg_noDataZeros( ...
                      load_nii(obj.dbase.parenchyma_filename), {petnii}, {mr0nii})
            petb   = NiiBrowser( petnii).rescale_to_mean( parnii);
            mr0b   = NiiBrowser(mr0nii).rescale_to_mean(parnii);
            props1 = ScatterPublisher.makePrintProps;
            disp('please inspect scatter..........');
            mlpublish.ScatterPublisher.makeScatterFromNii( ...
                petb.nii, ...
                mr0b.nii, ...
                parnii, props1)
        end
        
        function obj = test_makeScatterTissTypes(obj)
            
            if (~obj.torun(8)); return; end;
            obj = obj.prep_nii;                        
            import mlfourd.*;
            import mlpublish.*;                  
            petniis   = cell(4,1);
            mr0niis   = cell(4,1);
            mr1niis   = cell(4,1);
            roiniis    = cell(4,1);
            roiniis{1} = load_nii(obj.dbase.grey_filename);
            roiniis{2} = load_nii(obj.dbase.white_filename);
            roiniis{3} = load_nii(obj.dbase.csf_filename);
            roiniis{4} = load_nii(obj.dbase.art_filename);           
            for s = 1:4
                if (strcmp('np287', obj.dbase.sid))
                    roiniis{s}.img = ...
                        double(obj.bayes_slices_mask(obj.mr1nii, roiniis{s}.img));    
                end
                disp([ ...
         '***** petniis{' num2str(s) '}:']);
                petniis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.petnii, ...
                    obj.petnii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                     obj.petnii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
                disp([ ...
         '***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = mlfourd.NiiBrowser.make_nii_like(obj.mr0nii, ...
                    obj.mr0nii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
                disp([ ...
         '***** mr1niis{' num2str(s) '}:']);
                mr1niis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.mr1nii, ...
                    obj.mr1nii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                     obj.mr1nii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
            end            
            disp( ...
         '***** please inspect scatters .................');
            obj.props                 = ScatterPublisher.makeDefaultPrintProps(...
                                        {'grey' 'white' 'csf' 'arteries'});
            obj.props.filenameStemEps = ['PET CBF vs MR SVD CBF ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                                       petniis, mr0niis, roiniis, obj.props)
            obj.props.filenameStemEps = ['PET CBF vs MR qCBF' datestr(now,30)];

            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                                       petniis, mr1niis, roiniis, obj.props)
        end
        
        function obj = test_makeScatterBlockedTissTypes(obj)
            
            if (~obj.torun(9)); return; end;
            obj = obj.prep_properties;
            obj = obj.prep_blocked_nii;
            import mlfourd.*;
            import mlpublish.*;                  
            petniis   = cell(2,1);
            mr1niis   = cell(2,1);
            roiniis    = cell(2,1);
            %roiniis{1} = load_nii(obj.dbase.art_filename(  true, true));
            %roiniis{2} = load_nii(obj.dbase.csf_filename(  true, true)); 
            roiniis{1} = load_nii(obj.dbase.white_filename(true, true));
            roiniis{2} = load_nii(obj.dbase.grey_filename( true, true));
            for s = 1:length(roiniis)
                if (strcmp(obj.dbase.sid, 'np287'))
                    roiniis{s}.img = ...
                        double(obj.bayes_slices_mask(obj.mr1nii, roiniis{s}.img));
                end
                disp([ ...
         '***** petniis{' num2str(s) '}:']);
                petniis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.petnii, ...
                    obj.petnii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.petnii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
                disp([ ...
         '***** mr1niis{' num2str(s) '}:']);
                mr1niis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.mr1nii, ...
                    obj.mr1nii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr1nii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
            end            
            disp( ...
         '***** please inspect scatters .................');
            obj.props                    = mlpublish.ScatterPublisher.makeDefaultPrintProps( ...
                                           {'white' 'grey'});
            obj.props.aTitle             = '';
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = false;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = true;
            obj.props.globalRegression   = false;
            for r = 1:numel(obj.props.lineWidths)
                obj.props.lineWidths{r}           = 2.0;
                obj.props.confidenceLineWidths{r} = 1.0;
                obj.props.regressLineWidths{r}    = 2.0;
            end
%             
%             obj.dbase.iscomparator    = true;
%             obj.props.anXLim          = [0 70];
%             % obj.props.aYLim           = [0 70];
%             obj.props.anXLim_BA       = [0 70];
%             obj.props.aYLim_BA        = [-40 30];
%             obj.props.anXLabel        = 'PET OEF';
%             obj.props.aYLabel         = 'qCBF';
%             obj.props.anXLabel_BA     = 'N/A'; % 'Mean \{ MR SVD CBF,  Perm.-Corrected PET CBF \}';
%             obj.props.aYLabel_BA      = 'N/A'; %         'MR SVD CBF - Perm.-Corrected PET CBF ';
%             obj.props.filenameStemEps = ['PET OEF vs qCBF 8x8x2 ' datestr(now,30)];
%             mlpublish.ScatterPublisher.makeScatterFromNiis( ...
%                                        petniis, mr0niis, roiniis, obj.props)
            obj.dbase.iscomparator    = false;
            obj.props.anXLim          = [0 .5];
            obj.props.aYLim           = [0 35];
            obj.props.anXLim_BA       = [-.5 .5];
            obj.props.aYLim_BA        = [-5 5];
            obj.props.anXLabel        = 'PET OEF';
            obj.props.aYLabel         = 'qCBF'; 
            obj.props.anXLabel_BA     = 'N/A'; %'Mean \{ MR qCBF,  Perm.-Corrected PET CBF \}';
            obj.props.aYLabel_BA      = 'N/A'; %        'MR qCBF - Perm.-Corrected PET CBF ';
            obj.props.filenameStemEps = ['PET OEF vs qCBF 8x8x2 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                                       petniis, mr1niis, roiniis, obj.props)
        end
        
        function obj = test_makeStandardizedMoments(obj)
            
            if (~obj.torun(10)); return; end;
            obj = obj.prep_properties(obj.dbase.pid, 3);
            obj = obj.prep_blocked_nii;            
            obj.dbase.ref_series     = '';
            obj.dbase.pet_ref_series = '';
            obj.props = mlpublish.ScatterPublisher.makeDefaultPrintProps(3);
            import mlfourd.*;
            import mlpublish.*; 
            import mlpublish_test.*;
            petniis   = cell(3,1);
            mr0niis   = cell(3,1);
            mr1niis   = cell(3,1);
            roiniis    = cell(3,1);
            roiniis{1} = load_nii([obj.dbase.fg_path 'parenchyma' obj.dbase.ref_series obj.dbase.block_suffix obj.dbase.img_format]);
            roiniis{2} = load_nii([obj.dbase.fg_path 'csf'        obj.dbase.ref_series obj.dbase.block_suffix obj.dbase.img_format]);
            roiniis{3} = load_nii([obj.dbase.fg_path 'arteries'   obj.dbase.ref_series obj.dbase.block_suffix obj.dbase.img_format]);            
            for s = 1:3
                roiniis{s}.img =  ...
                    double(obj.bayes_slices_mask(obj.mr1nii, roiniis{s}.img));
                disp([ ...
         '***** petniis{' num2str(s) '}:']);
                petniis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.petnii, ...
                    obj.petnii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                     obj.petnii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
                disp([ ...
         '***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = mlfourd.NiiBrowser.make_nii_like(obj.mr0nii, ...
                    obj.mr0nii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
                disp([ ...
         '***** mr1niis{' num2str(s) '}:']);
                mr1niis{s}  = mlfourd.NiiBrowser.make_nii_like(obj.mr1nii, ...
                    obj.mr1nii.img .* roiniis{s}.img, ...
                   ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                     obj.mr1nii.hdr.hist.descrip ' ^ ' roiniis{s}.hdr.hist.descrip])
            end            
            disp( ...
         '***** please inspect scatters .................');
            obj.props.aTitle             = '';            
            obj.props.switches           = [ 1 0 0 ];
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = false;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = true;      
            obj.props.aYLabel         = 'MR MLEM CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (MR MLEM CBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (MR MLEM CBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['Stnd Moment PET CBF vs MR MLEM CBF 10x10x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                                       petniis, mr0niis, roiniis, obj.props)
            obj.props.aYLabel         = 'MR LAIF CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (MR LAIF CBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (MR LAIF CBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['Stnd Moment PET CBF vs MR LAIF CBF 10X10x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                                       petniis, mr1niis, roiniis, obj.props)
        end
                

        
        
        function obj = test_3patients(obj)
            
            if (~obj.torun(11)); return; end;            
            petniis   = cell(3,1);
            mr0niis  = cell(3,1);
            mr1niis  = cell(3,1);
            parniis    = cell(3,1);
            pids      = { 'p5777' 'p5772' 'p5740' };  % p5781
            import mlfourd.*;
            import mlpublish.*;
            import mlpublish_test.*;
            for s = 1:length(pids)
                obj = obj.prep_properties(pids{s}, 3);
                obj = obj.prep_blocked_nii;
                parniis{s}     = load_nii([obj.dbase.fg_path 'parenchyma_8x8x1' obj.dbase.img_format]);
                parniis{s}.img = double(obj.bayes_slices_mask(obj.mr1nii, parniis{s}.img));
                disp(['***** petniis{' num2str(s) '}:']);
                petniis{s}  = NiiBrowser.make_nii_like(...
                    obj.petnii, ...
                    obj.petnii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                      obj.petnii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr0nii, ...
                    obj.mr0nii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr1niis{' num2str(s) '}:']);
                mr1niis{s}  = NiiBrowser.make_nii_like(...
                    obj.mr1nii, ...
                    obj.mr1nii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr1nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
            end
            disp('***** please inspect scatters .................');
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = true;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = false;
            obj.props.aYLabel         = 'MR SVD CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (MR SVD CBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (MR SVD CBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['3-Patients PET CBF vs MR SVD CBF 8x8x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr0niis, parniis, obj.props)
            obj.props.aYLabel         = 'qCBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (qCBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (qCBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['3-Patients PET CBF vs qCBF 8x8x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr1niis, parniis, obj.props)
        end % function test_3patients
        
        
        
        function obj = test_4patients(obj)
            
            if (~obj.torun(12)); return; end;            
            petniis   = cell(4,1);
            mr0niis  = cell(4,1);
            mr1niis  = cell(4,1);
            parniis    = cell(4,1);
            pids      = { 'p5777' 'p5772' 'p5740' 'p5781' };  
            import mlfourd.*;
            import mlpublish.*;
            import mlpublish_test.*;
            for s = 1:length(pids)
                obj = obj.prep_properties(pids{s}, 4);
                obj = obj.prep_blocked_nii;
                parniis{s}     = load_nii([obj.dbase.fg_path 'parenchyma_8x8x1' obj.dbase.img_format]);
                parniis{s}.img = double(obj.bayes_slices_mask(obj.mr1nii, parniis{s}.img));
                disp(['***** petniis{' num2str(s) '}:']);
                petniis{s}  = NiiBrowser.make_nii_like(...
                    obj.petnii, ...
                    obj.petnii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                      obj.petnii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr0nii, ...
                    obj.mr0nii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr1niis{' num2str(s) '}:']);
                mr1niis{s}  = NiiBrowser.make_nii_like(...
                    obj.mr1nii, ...
                    obj.mr1nii.img .* parniis{s}.img, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr1nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
            end
            disp('***** please inspect scatters .................');
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = true;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = false;
            obj.props.aYLabel         = 'MR SVD CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (MR SVD CBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (MR SVD CBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['4-Patients PET CBF vs MR SVD CBF 8x8x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr0niis, parniis, obj.props)
            obj.props.aYLabel         = 'qCBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ \mu_{\sigma} (qCBF),  \mu_{\sigma} (Perm.-Corrected PET CBF) \}';
            obj.props.aYLabel_BA      =         '\mu_{\sigma} (qCBF) - \mu_{\sigma} (Perm.-Corrected PET CBF)';
            obj.props.filenameStemEps = ['4-Patients PET CBF vs qCBF 8x8x1 ' datestr(now,30)];
            mlpublish.ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr1niis, parniis, obj.props)
        end % function test_4patients

        function obj = test_patients_np287(obj)
            
            TISSUE  = 'parenchyma';           
            if (~obj.torun(13)); return; end; 
            obj = obj.prep_properties; 
            pids    = { 'vc4103' 'vc4336' 'vc4405' 'vc4420' 'vc4426' ...
                        'vc4437' 'vc4497' 'vc4500' 'vc4520' 'vc4634' ...
                        'vc4903' 'vc5591' 'vc5625' 'vc5821'              };
            petniis = cell(length(pids),1);
            mr0niis = cell(length(pids),1);
            mr1niis = cell(length(pids),1);
            parniis = cell(length(pids),1);
            import mlfourd.*;
            import mlpublish.*;
            import mlpublish_test.*;
            for s = 1:length(pids)
                obj = obj.prep_properties(pids{s}, length(pids));
                obj = obj.prep_blocked_nii;
                obj.dbase.ref_series     = '';
                obj.dbase.pet_ref_series = '';
                parniis{s}     = load_nii(obj.dbase.parenchyma_filename(true, true));
                parniis{s}.img = double(obj.bayes_slices_mask(obj.mr1nii, parniis{s}.img));
                parimg         = dip_image(parniis{s}.img); % make visible to DEBUG
                disp(['***** petniis{' num2str(s) '}:']);
                petniis{s} = NiiBrowser.make_nii_like(...
                    obj.petnii, ...
                    obj.petnii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                      obj.petnii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr0nii, ...
                    obj.mr0nii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr1niis{' num2str(s) '}:']);
                mr1niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr1nii, ...
                    obj.mr1nii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr1nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
            end
            disp('***** please inspect scatters .................');
            obj.props.globalRegression   = true;
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = false;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = true;
            obj.props.regressionRequests = { 1 1 1 1 1   1 1 1 1 1   1 1 1 1 }; % { 0 0 0 0 0  0 0 0 0 0  0 0 0 0 };
            obj.props.aTitle             = '14 Patients, Parenchyma Only';
            obj.props.aYLim              = [0 1.5];
            obj.props.anXLim_BA          = [-2.5, 4];
            F                            = '\mu_\sigma';
            grid                         = obj.dbase.block_suffix;
            grid                         = grid(2:length(grid));
            obj.props.aYLabel            = ['MR MLEM CBF / Arbitrary'];
            obj.props.anXLabel_BA        = ['Mean \{ ' F '(MR MLEM CBF), '  F '(Corrected PET CBF) \}'];
            obj.props.aYLabel_BA         = [           F '(MR MLEM CBF) - ' F '(Corrected PET CBF) '];
            obj.props.filenameStemEps    = ['14-Patients PET CBF vs MR MLEM CBF ' grid ' ' TISSUE ' ' datestr(now,30)];
            obj.dbase.iscomparator       = true;
            ScatterPublisher.makeScatterFromNiis(petniis, mr0niis, parniis, obj.props)            
            obj.props.aYLim              = [0 10];
            obj.props.anXLim_BA          = [-2.5, 4];
            obj.props.aYLabel            = ['MR LAIF CBF / Arbitrary'];
            obj.props.anXLabel_BA        = ['Mean \{ ' F '(MR LAIF CBF), '  F '(Corrected PET CBF) \}'];
            obj.props.aYLabel_BA         = [           F '(MR LAIF CBF) - ' F '(Corrected PET CBF) '];
            obj.props.filenameStemEps    = ['14-Patients PET CBF vs MR LAIF CBF ' grid ' ' TISSUE ' ' datestr(now,30)];
            obj.dbase.iscomparator       = false;
            ScatterPublisher.makeScatterFromNiis(petniis, mr1niis, parniis, obj.props)
        end % end function test_patients_np287  
                
        function obj = test_patients_np797(obj)
            
            CUT_OFF = 0.5;
            TISSUE  = 'parenchyma';
            
            if (~obj.torun(14)); return; end; 
            obj = obj.prep_properties; 
            pids    = { 'p7153' 'p7189' 'p7191' 'p7194' 'p7217' ...
                        'p7229' 'p7230' 'p7243' 'p7248' 'p7260' ...
                        'p7266' 'p7267' 'p7270' 'p7321' 'p7335' ...
                        'p7336' 'p7338'  };
            petniis = cell(length(pids),1);
            mr0niis = cell(length(pids),1);
            mr1niis = cell(length(pids),1);
            parniis  = cell(length(pids),1);
            import mlfourd.*;
            import mlpublish.*;
            for s = 1:length(pids)
                obj = obj.prep_properties(pids{s}, length(pids));
                obj = obj.prep_blocked_nii;
                parniis{s}  = load_nii(obj.dbase.parenchyma_filename(true, true));
                parimg      = dip_image(parniis{s}.img);
                parimg      = double(parimg); % double(parimg > CUT_OFF*max(parimg)); %  
                disp(['***** petniis{' num2str(s) '}:']);
                petniis{s} = NiiBrowser.make_nii_like(...
                    obj.petnii, ...
                    obj.petnii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                      obj.petnii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr0niis{' num2str(s) '}:']);
                mr0niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr0nii, ...
                    obj.mr0nii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr0nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
                disp(['***** mr1niis{' num2str(s) '}:']);
                mr1niis{s} = NiiBrowser.make_nii_like(...
                    obj.mr1nii, ...
                    obj.mr1nii.img .* parimg, ...
                    ['Test_ScatterPublisher.test_makeScatterTissTypes:  ' ...
                    obj.mr1nii.hdr.hist.descrip ' ^ ' parniis{s}.hdr.hist.descrip])
            end
            disp('***** please inspect scatters .................');
            obj.props.globalRegression   = true;
            obj.props.rescale_to_mean    = false;
            obj.props.rescale_BA_to_mean = false;
            obj.props.stdMoment          = false;
            obj.props.stdMoment_BA       = false;
            obj.props.regressionRequests = { 1 1 1 1 1   1 1 1 1 1   1 1 1 1 1   1 1 }; % { 0 0 0 0 0  0 0 0 0 0  0 0 0 0 };
            obj.props.aTitle          = upper(TISSUE);
            obj.props.aYLabel         = 'MLEM CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ MLEM CBF,  Perm.-Corrected PET CBF \}';
            obj.props.aYLabel_BA      =         'MLEM CBF - Perm.-Corrected PET CBF ';
            obj.props.filenameStemEps = ['14-Patients PET CBF vs MLEM CBF 10x10x1 ' TISSUE ' ' datestr(now,30)];
            obj.dbase.iscomparator    = true;
            ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr0niis, parniis, obj.props)
            obj.props.aYLabel         = 'LAIF CBF / Arbitrary';
            obj.props.anXLabel_BA     = 'Mean \{ LAIF CBF,  Perm.-Corrected PET CBF \}';
            obj.props.aYLabel_BA      =         'LAIF CBF - Perm.-Corrected PET CBF ';
            obj.props.filenameStemEps = ['14-Patients PET CBF vs LAIF CBF 10x10x1 ' TISSUE ' ' datestr(now,30)];
            obj.dbase.iscomparator    = false;
            ScatterPublisher.makeScatterFromNiis( ...
                petniis, mr1niis, parniis, obj.props)            
        end % function test_patients_np797
        
        function obj = test_fixNii(obj)
            if (~obj.torun(15)); return; end; 
            obj = obj.prep_properties; 
            obj.dbase.ref_series      = '';
            obj.dbase.pet_ref_series  = '';
            pids    = { 'vc4103' 'vc4336' 'vc4405' 'vc4420' 'vc4426' ...
                        'vc4437' 'vc4497' 'vc4500' 'vc4520' 'vc4634' ...
                        'vc4903' 'vc5591' 'vc5625' 'vc5821'              };
            petniis = cell(length(pids),1);
            mr0niis = cell(length(pids),1);
            mr1niis = cell(length(pids),1);
            parniis = cell(length(pids),1);
            import mlfourd.*;
            import mlpublish.*;
            for s = 1:length(pids)              
                obj = obj.prep_properties(pids{s}, length(pids));
                obj = obj.prep_blocked_nii;
                petniis{s} = obj.fix_pixdim(obj.petnii);
                mr0niis{s} = obj.fix_pixdim(obj.mr0nii);
                mr1niis{s} = obj.fix_pixdim(obj.mr1nii);
                parniis{s} = obj.fix_pixdim(obj.parnii);
            end
        end % function test_fixNii
        
        %% FUNCTION FIX_PIXDIM
        %  upon passing fix_pixdim a NIfTI, it refreshes the pixdim values multiplied by the 
        %  block-sizes globally set in mlfourd.DBase, then returns the NIfTI.
        %
        %  Usage:  nii = fix_pixdim(id, saveit)
        %          ^ NIfTI          ^ NIfTI or filename
        %                                    ^ save result to disk?  (boolean)
        %          must 1st run, e.g.:  obj = obj.prep_properties('vc4103', 14);
        %                               obj = obj.prep_blocked_nii;
        function nii = fix_pixdim(obj, id, saveit)
            switch (nargin)
                case 3
                case 2
                    saveit = true; 
                otherwise
                    error('mlpublish_test:MissingParamsErr', ...
                        ['use at minimum fix_pixdim(pid); last nargin->' num2str(nargin)]); 
            end
            if     (ischar(id))
                try
                    nii = load_nii(id);
                catch ME
                    disp(ME.message);
                    error('mlpublish_test:IOErr', ['id->' id ' but was not a filename as expected']);
                end
            elseif (isNIfTI(id))
                nii = id;
            else
                error('mlpublish_test:PassedParamErr', ['could not recognize id, class->' class(id)]);
            end               
            factor     = ones(1,length(obj.parnii.hdr.dime.pixdim));
            factor(2)  = obj.dbase.blockSize(1);
            factor(3)  = obj.dbase.blockSize(2);
            factor(4)  = obj.dbase.blockSize(3);
            disp( 'Test_ScatterPublisher.fix_pixdim:'); 
            disp(['     updating nii.hdr.dime.pixdim (' nii.hdr.hist.descrip ')']);
            disp(['     from ' num2str(nii.hdr.dime.pixdim)]);
                                       nii.hdr.dime.pixdim = [1 9.375 9.375 6 1 1 1 1]; % factor .* nii.hdr.dime.pixdim;
            disp(['     to   ' num2str(nii.hdr.dime.pixdim)]);
            if (saveit)
                disp(['refreshing contents of ' nii.fileprefix '.nii.gz; other file suffixes will be deleted']);
                delete(       [nii.fileprefix '.*']);
                save_nii(nii, [nii.fileprefix '.nii.gz']); 
            end
        end % function fix_pixdim

        
        
        %%       CTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj  = Test_ScatterPublisher(varargin)
            obj       = obj@mlunit.test_case(varargin{:});
            obj       = obj.prep_properties;    
            %%system(['cd ' obj.dbase.patient path '; gzip *.nii']);
        end
        
        function obj = tear_down(obj)
        end
        
        function obj = prep_properties(obj, apid, len)
            switch (nargin)
                case 1
                    obj.dbase = mlfourd.DBase.getInstance;
                otherwise
                    obj.dbase = mlfourd.DBase.getInstance(apid);                     
            end     
            if (nargin > 2)
                obj.props = mlpublish.ScatterPublisher.makeDefaultPrintProps(len);
            else
                obj.props = mlpublish.ScatterPublisher.makeDefaultPrintProps;
            end 
            mlpublish.ScatterPublisher.checkProps(obj.props); 
        end
        
        function obj = prep_nii(obj) 
            obj.petnii = load_nii(obj.dbase.pet_filename('cbf')); 
            %obj.mr0nii = load_nii(obj.dbase.mr0_filename('cbf'));
            obj.mr1nii = load_nii(obj.dbase.mr1_filename('cbf'));          
            obj.parnii = load_nii(obj.dbase.parenchyma_filename); 
            assert(isNIfTI(obj.petnii));
            assert(isNIfTI(obj.mr1nii));
            assert(isNIfTI(obj.mr0nii));
            assert(isNIfTI(obj.parnii));
        end
        
        function obj = prep_blocked_nii(obj) 
            obj.petnii = load_nii(obj.dbase.pet_filename('oef',     true, true));           
            %obj.mr0nii = load_nii(obj.dbase.mr0_filename('cbf', true, true));
            obj.mr1nii = load_nii(obj.dbase.mr1_filename('cbf', true, true)); 
            %obj.parnii = load_nii(obj.dbase.parenchyma_filename(    true, true)); 
            assert(isNIfTI(obj.petnii));
            assert(isNIfTI(obj.mr1nii));
            %assert(isNIfTI(obj.mr0nii));
            %assert(isNIfTI(obj.parnii));
        end
    end % methods
    
    methods (Static)
        
        function msk = bayes_slices_mask(bayesnii, msk0)
            
            sizes = size(bayesnii.img);
            if (nargin < 2); msk0 = ones(sizes); end
            msk   = zeros(sizes);
            for s = 1:sizes(3)
                if (sum(sum(bayesnii.img(:,:,s))) > 0)
                    msk(:,:,s) = msk0(:,:,s);
                end
            end
        end
        
        function nii1 = normMask(msknii)
            integral = sum(dip_image(double(msknii.img)));
            nii1     = mlfourd.NiiBrowser.make_nii_like( ...
                       msknii, msknii.img/integral, ['normalized ' msknii.hdr.hist.descrip]);
        end
        
        function img1 = normImg(mskimg)
            integral = sum(dip_image(double(mskimg)));
            img1     = mskimg/integral;
        end
    end
end
