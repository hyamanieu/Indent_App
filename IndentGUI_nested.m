classdef IndentGUI_nested < handle
    %IndentGUI_nested
    %   IndentGUI_nested starts a GUI for opening and processing .csv and .xls
    %   output files from Nanoindenters.
    %
    %   How to use:     
    %   
    %
    %   v2.3
    %   Copyright 2015 Hugues-Yanis Amanieu
    %    Licensed under the Apache License, Version 2.0 (the "License");
    %    you may not use this file except in compliance with the License.
    %    You may obtain a copy of the License at
    %
    %      http://www.apache.org/licenses/LICENSE-2.0
    %
    %    Unless required by applicable law or agreed to in writing, software
    %    distributed under the License is distributed on an "AS IS" BASIS,
    %    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    %    See the License for the specific language governing permissions and
    %    limitations under the License.
    
    % VERSIONS:
    %   v1.0 - first version.
    %   v1.1 - Added filter. See Paper
    %   v2 - matlab class, new GUI
    %   v2.1 - small bug correction
    %   v2.2 - now applies both filters on all tests
    %   v2.2b - Bug fixes
    %   v2.3 - Visual improvements for release
    properties (SetAccess=private)
        verNumber = '2.3';
    end
    
    properties (Hidden, Access=protected)
        handles
    end
    
    
    
    methods
        function  obj = IndentGUI_nested(dirname)
            
            
            
            if nargin == 0
                dirname = pwd;
            else
                if ~ischar(dirname) || ~isdir(dirname)
                    error('Invalid input argument.\n  Syntax: %s(DIRNAME)', upper(mfilename));
                end
            end
            
            %Delete other instance of IndentGUI
            delete(findall(0, 'type', 'figure', 'tag', 'IndentGUI'));
            
            
            bgcolor1 = [.8 .8 .8];
            txtcolor = [.3 .3 .3];
            
            figH = figure(...
                'units'                         , 'normalized', ...
                'busyaction'                    , 'queue', ...
                'color'                         , bgcolor1, ...
                'doublebuffer'                  , 'on', ...
                'handlevisibility'              , 'on', ...
                'interruptible'                 , 'on', ...
                'menubar'                       , 'none', ...
                'name'                          , upper(mfilename), ...
                'numbertitle'                   , 'off', ...
                'Unit'                          , 'Pixel',...
                'outerposition'                 , [100 100 600 400], ...
                'resize'                        , 'on', ...
                'resizefcn'                     , @obj.resizeFcn, ...
                'tag'                           , 'IndentGUI', ...
                'toolbar'                       , 'none', ...
                'visible'                       , 'off', ...
                'defaultaxesunits'              , 'pixels', ...
                'defaulttextfontunits'          , 'pixels', ...
                'defaulttextfontname'           , 'Verdana', ...
                'defaulttextfontsize'           , 12, ...
                'defaultuicontrolunits'         , 'pixels', ...
                'defaultuicontrolfontunits'     , 'pixels', ...
                'defaultuicontrolfontsize'      , 10, ...
                'defaultuicontrolfontname'      , 'Verdana', ...
                'defaultuicontrolinterruptible' , 'off', ...
                'Renderer'                      ,'painter', ...
                'HitTest'                       ,'off');
            
            
            % menu bar.
            fileMh = uimenu('Label','file');
            uimenu(fileMh,'Label','Save structure','Callback',@obj.ToWorkspace);
            uimenu(fileMh,'Label','Open structure','Callback',@obj.FromWorkspace);
            uimenu(fileMh,'Label','file 2 struct','Callback',{@obj.Open_Callback,1},'Separator','on');
            uimenu(fileMh,'Label','file 2 struct (no test)','Callback',{@obj.Open_Callback,0});
            editMh = uimenu('Label','edit');
            uimenu(editMh,'Label','Change av. disp.','Callback',@obj.editDisp_Callback);
            uimenu(editMh,'Label','Calibrate Image','Callback',@obj.ImageCali_Callback);
            filterMh = uimenu('Label','filter');
            uimenu(filterMh,'Label',' filter properties','Callback',@obj.filtProp_Callback);
            uimenu(filterMh,'Label',' Filter!','Callback',@obj.filter_Callback);
            uimenu(filterMh,'Label','Deconvolution','Callback',@obj.Deconvolution,'Separator','on');
            helpMh = uimenu('Label','help');
            uimenu(helpMh,'Label','Help','Callback',@help_Callback);
            uimenu(helpMh,'Label','about','Callback',@about_Callback);

            
            %Data table push button
            TableH= uicontrol(...
                'style'                     , 'pushbutton', ...
                'backgroundcolor'           , bgcolor1, ...
                'callback'                  , @obj.Table_Callback, ...
                'parent'                    , figH, ...
                'String'                    , 'Spreadsheet',...
                'FontSize'                  , 16, ...
                'tag'                       , 'Table');
            
            
            %Test frame
            testPanH = uipanel(...
                'units'                     , 'pixels', ...
                'bordertype'                , 'etchedout', ...
                'backgroundcolor'           , bgcolor1, ...
                'fontname'                  , 'Verdana', ...
                'fontsize'                  , 10, ...
                'fontweight'                , 'bold', ...
                'title'                     , 'Test plot options', ...
                'titleposition'             , 'centertop', ...
                'parent'                    , figH, ...
                'tag'                       , 'plotPan');
            
            testListH = uicontrol(...
                'style'                     , 'listbox', ...
                'Min'                       ,1,...
                'Max'                       ,10,...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'empty',...
                'Callback'                  , @obj.testlist_Callback,...
                'FontSize'                  , 16, ...
                'tag'                       , 'testlist');
            
            XvarH = uicontrol(...
                'style'                     , 'popupmenu', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'empty',...
                'FontSize'                  , 16, ...
                'tag'                       , 'X_var');
            
            YvarH = uicontrol(...
                'style'                     , 'popupmenu', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'empty',...
                'FontSize'                  , 16, ...
                'tag'                       , 'Y_var');
            
            XtxtH= uicontrol(...
                'style'                     , 'text', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'X-axis',...
                'FontSize'                  , 16, ...
                'tag'                       , 'textX');
            
            YtxtH= uicontrol(...
                'style'                     , 'text', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'Y-axis',...
                'FontSize'                  , 16, ...
                'tag'                       , 'textY');
            
            PlotH= uicontrol(...
                'style'                     , 'pushbutton', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , testPanH, ...
                'String'                    , 'PLOT',...
                'callback'                  ,@obj.Plot_Callback,...
                'FontSize'                  , 16, ...
                'tag'                       , 'Plot');
            
            
            %Map frame
            mapPanH = uipanel(...
                'units'                     , 'pixels', ...
                'bordertype'                , 'etchedout', ...
                'backgroundcolor'           , bgcolor1, ...
                'fontname'                  , 'Verdana', ...
                'fontsize'                  , 10, ...
                'fontweight'                , 'bold', ...
                'title'                     , 'Mapping options', ...
                'titleposition'             , 'centertop', ...
                'parent'                    , figH, ...
                'tag'                       , 'mapPan');
            Map3DH= uicontrol(...
                'style'                     , 'checkbox', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , mapPanH, ...
                'String'                    , '3D map',...
                'FontSize'                  , 16, ...
                'tag'                       , 'Map3D');
            MapH= uicontrol(...
                'style'                     , 'pushbutton', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , mapPanH, ...
                'Callback'                  , @obj.MapIndentB_Callback, ...
                'String'                    , 'Map Indent',...
                'FontSize'                  , 16, ...
                'tag'                       , 'Map');
            SliderH= uicontrol(...
                'style'                     , 'slider', ...
                'backgroundcolor'           , bgcolor1, ...
                'parent'                    , mapPanH, ...
                'FontSize'                  , 16, ...
                'Callback'                  ,@obj.transparency_Callback,...
                'tag'                       , 'transparency');
            SliderTxtH(1)= uicontrol(...
                'style'                     , 'text', ...
                'backgroundcolor'           , bgcolor1, ...
                'String'                    , 'Map',...
                'parent'                    , mapPanH, ...
                'FontSize'                  , 16, ...
                'tag'                       , 'textMap');
            SliderTxtH(2)= uicontrol(...
                'style'                     , 'text', ...
                'backgroundcolor'           , bgcolor1, ...
                'String'                    , 'Image',...
                'parent'                    , mapPanH, ...
                'FontSize'                  , 16, ...
                'tag'                       , 'textIm');
            
            
           
            
            obj.handles             = guihandles(figH);
            obj.handles.figPos      = [];
            obj.handles.lastDir     = dirname;%Last directory where test was selected.
            obj.handles.data        = struct();% Indentation data saved in a structure
            obj.handles.Rec         =[];%List of handles of all the rectangles showing test selection
            obj.handles.Eaxes       =[];%Axes of the 2D map where tests can be selected.            
            obj.handles.imgdata     =[];%Image handle
            obj.handles.Imxy        =[];%Position of image as compared to indentation data
            
            
            %%Shape of the rectangle (for visilibity)
            obj.handles.SelectIm=struct('cdata',zeros(16,16,3),'alpha',zeros(16,16,1));
            for i=1:3
                obj.handles.SelectIm.cdata(:,:,i) =...
                    [0         0         0         0         0         0         0    1.0000    1.0000         0         0         0         0         0         0         0
                    0    0.7500    0.7500    0.7500    0.7500    0.7500    0.7500    1.0000    1.0000    0.7500    0.7500    0.7500    0.7500    0.7500    0.7500         0
                    0    0.7500         0         0         0         0         0    1.0000    1.0000         0         0         0         0         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000
                    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000         0    0.7500         0
                    0    0.7500         0         0         0         0         0    1.0000    1.0000         0         0         0         0         0    0.7500         0
                    0    0.7500    0.7500    0.7500    0.7500    0.7500    0.7500    1.0000    1.0000    0.7500    0.7500    0.7500    0.7500    0.7500    0.7500         0
                    0         0         0         0         0         0         0    1.0000    1.0000         0         0         0         0         0         0         0];
            end
            obj.handles.SelectIm.alpha= ...
                [1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1
                1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1
                1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     1
                1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1
                1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1
                1     1     1     1     1     1     1     0     0     1     1     1     1     1     1     1];
            
            
            %Filter properties
            filtProp=zeros(5,1);
            filtProp(1)=0;%Quadratic fit minimum depth
            filtProp(2)=0;%Quadratic fit maximum depth
            filtProp(3)=4e-03;%Resodial threshold for quandratic fit
            filtProp(4)=45;%Minimum depth for calculating structural compliance
            filtProp(5)=4e-6;%Structural compliance threshold
            obj.handles.filtProp=filtProp;
            
            
            
            resizeFcn(obj);
            set(figH, 'visible', 'on');
        end
        
        %--------------------------------------------------------------------------
        % resetGUI
        %   reset the GUI as if it were just opened.
        %--------------------------------------------------------------------------
        function resetGUI(obj, varargin)
            obj.handles.data = struct();
            set(obj.handles.testlist,'Value',1);
            set(obj.handles.testlist,'String','empty');%test list is set
            set(obj.handles.X_var,'String','empty');
            set(obj.handles.Y_var,'String','empty');
        end
        
        %--------------------------------------------------------------------------
        % resizeFcn
        %   This resizes the figure window appropriately
        %--------------------------------------------------------------------------
        function resizeFcn(obj, varargin)
            
            set(obj.handles.IndentGUI, 'units', 'pixels');
            figPos = get(obj.handles.IndentGUI, 'position');
            
            %Check if big enough
            if figPos(3) < 600 || figPos(4) < 300
                figPos(3) = max([600 figPos(3)]);
                figPos(4) = max([300 figPos(4)]);
                
                set(obj.handles.IndentGUI, 'position', figPos);
                
            end
            
            %Position and size of each object
            set(obj.handles.Table                , 'position', [1, 1, 150, 25]);
            set(obj.handles.plotPan              , 'position', [1, 30, figPos(3)/2-10, figPos(4)-40]);%Position uipanel to plot tests
            set(obj.handles.mapPan               , 'position', [figPos(3)/2+10, 30, figPos(3)/2-10, figPos(4)-40]);%Position uipanel to plot map
            
            %Position and size of each object within the uipanel plotPan
            set(obj.handles.testlist           , 'position', [2, 2, figPos(3)/2-180, figPos(4)-70]);
            set(obj.handles.textX               , 'position', [figPos(3)/2-170,figPos(4)-110, 150, 30]);
            set(obj.handles.X_var               , 'position', [figPos(3)/2-170,figPos(4)-140, 150, 30]);
            set(obj.handles.textY               , 'position', [figPos(3)/2-170,figPos(4)-170, 150, 30]);
            set(obj.handles.Y_var               , 'position', [figPos(3)/2-170,figPos(4)-200, 150, 30]);
            set(obj.handles.Plot               , 'position', [figPos(3)/2-170,figPos(4)-250, 150, 40]);
            
            %Position and size of each object within the uipanel mapPan
            set(obj.handles.Map           , 'position', [2,figPos(4)-110, 150, 30]);
            set(obj.handles.Map3D               , 'position', [170,figPos(4)-110, 100, 30]);
            set(obj.handles.transparency               , 'position', [10,figPos(4)-190, figPos(3)/2-40 ,20 ]);
            set(obj.handles.textMap               , 'position', [2,figPos(4)-170, 50, 30]);
            set(obj.handles.textIm               , 'position', [figPos(3)/2-100,figPos(4)-170, 80, 30]);
            obj.handles.figPos = figPos;
        end
        
        %--------------------------------------------------------------------------
        % FromWorkspace
        %   Activate by a click on "Open structure". Import a structure
        %   from the workspace to the GUI
        %--------------------------------------------------------------------------
        function FromWorkspace(obj, varargin)
            
            %Check if data are already loaded.
            if ~isempty(fieldnames(obj.handles.data))
                selection = questdlg('data are already loaded, are you sure you want to load new data?',...
                    'Already loaded data',...
                    'Yes','No','Yes');
                switch selection,
                    case 'Yes',
                        resetGUI(obj);
                    case 'No'
                        return
                end
            end
            vars = evalin('base','who');
            f = figure('Position', [100 320 300 100], 'MenuBar', 'none','Name','LIST -- double-click to validate', 'NumberTitle','off');
            hlbox = uicontrol('style', 'listbox','value', 1,'String',vars,'Position', [0 0 300 100]);
            list_entries = get(hlbox,'String');
            count=0;
            a = get(f, 'SelectionType');
            uiwait(f,2)
            try
                while ~strcmp(get(f, 'SelectionType'),'open') && (count < 100000)
                    count = count +1;
                    try
                        waitforbuttonpress
                    catch ME
                        return
                    end
                end
            catch ME
                return
            end
            index_selected(1) = get(hlbox,'Value');
            data = list_entries{index_selected(1)};
            close(f);
            set(obj.handles.IndentGUI,'Name',sprintf(['IndentGUI: ',data,'\n loaded']));
            obj.handles.data = evalin('base',data);
            if any(strcmp(fieldnames(obj.handles.data),'tests'))
                TestList = cell(length(obj.handles.data.tests),1);%number of tests
                for i =1:length(TestList);
                    TestList{i}= ['Test ',int2str(i)];
                end
                set(obj.handles.testlist,'Value',1);
                set(obj.handles.testlist,'String',TestList);%test list is set
                set(obj.handles.X_var,'String',obj.handles.data.tlegend(1,:));
                set(obj.handles.Y_var,'String',obj.handles.data.tlegend(1,:));
            end
        end
        
        %--------------------------------------------------------------------------
        % ToWorkspace
        %   Activate by a click on "Save structure". Export a structure
        %   to the workspace from the GUI
        %--------------------------------------------------------------------------
        function ToWorkspace(obj, varargin)
            if isempty(fieldnames(obj.handles.data))
                errordlg('No data to save.');
                return
            end
            
            prompt = {'Give a name to the new structure name. If already existing, erase original data!'};
            dlg_title = 'Structure name';
            num_lines = 1;
            def = {''};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            if isempty(answer)
                return
            end
            Name=answer{1};
            Name=genvarname(Name);
            assignin('base',Name , obj.handles.data);
            helpdlg('Matlab structure saved on the workspace. For future use, please save the file manually (right click, ''Save As...''');
        end
        %--------------------------------------------------------------------------
        % Plot_Callback
        %   Activate by a click on "Plot". Plot data of tests.
        %--------------------------------------------------------------------------
        function Plot_Callback(obj, varargin)
            a=get(obj.handles.IndentGUI,'Name');a=a(1,:);
            fig = figure('Name',a, 'Color',[1 1 1]);
            set(fig,'units','normalized','outerposition',[0 0 1 1]);
            hold all;
            Xchoice = get(obj.handles.X_var,'Value');
            Ychoice = get(obj.handles.Y_var,'Value');
            Xnames = get(obj.handles.X_var,'String');
            Ynames = get(obj.handles.Y_var,'String');
            Tchoices = get(obj.handles.testlist,'value');
            
            %Transfer data from test structure to cells
            Tcell=cell(length(Tchoices));
            PlotLegend=[];
            for Tnumb=1:length(Tchoices)
                X=obj.handles.data.tests{Tchoices(Tnumb)}(:,Xchoice);
                Y=obj.handles.data.tests{Tchoices(Tnumb)}(:,Ychoice);
                plot(X(Y<10^10),Y(Y<10^10),'LineWidth',3);
                PlotLegend=[PlotLegend; 'Test ',num2str(Tchoices(Tnumb),'%03d')];
            end
            xlabel(strcat(Xnames(Xchoice),'(',obj.handles.data.tlegend(2,Xchoice),')'),'FontSize',14);
            ylabel(strcat(Ynames(Ychoice),'(',obj.handles.data.tlegend(2,Ychoice),')'),'FontSize',14);
            title(sprintf('''%s'' vs ''%s''', Xnames{Xchoice},Ynames{Ychoice}), 'FontSize',14);
            set(gca,'FontSize',14,'LineWidth',1.5);
            hleg1=legend(PlotLegend);
            set(hleg1,'Location','NorthWest')
        end
        
        function Open_Callback(obj, varargin)
            wTest = varargin{3};
            %Check if data are already loaded.
            if ~isempty(fieldnames(obj.handles.data))
                selection = questdlg('data are already loaded, are you sure you want to load new data?',...
                    'Already loaded data',...
                    'Yes','No','Yes');
                switch selection,
                    case 'Yes',
                        resetGUI(obj);
                    case 'No'
                        return
                end
            end
            
            %Look for files in last folder or input folder.
            
            if isempty(obj.handles.lastDir)
                obj.handles.lastDir = pwd;
            end
            
            
            %Open folders
            [filename, path, c] = uigetfile({'*.csv';'*.xls';'*.xlsx';'*.*'},'Select your csv or excel file',obj.handles.lastDir);
            obj.handles.lastDir = path;
            
            set(obj.handles.IndentGUI,'Name',sprintf('IndentGUI: Processing...\n Please wait'));
            pause(1);
            file = [path,filename];
            
            %Import test: Y/N
            if wTest
                [results, rlegend, tlegend, tests] = ImportXls(file);
                TestList = cell(length(tests),1);%number of tests
                for i =1:length(TestList);
                    TestList{i}= ['Test ',int2str(i)];
                end
                set(obj.handles.testlist,'Value',1);
                set(obj.handles.testlist,'String',TestList);%test list is set
                set(obj.handles.X_var,'String',tlegend(1,:));
                set(obj.handles.Y_var,'String',tlegend(1,:));
                obj.handles.data.tests= tests;
                obj.handles.data.tlegend=tlegend;
            else
                [results, rlegend] = ImportXls(file);
            end
            obj.handles.data.results = results;
            obj.handles.data.rlegend=rlegend;
            
            %Check what folder separator is used by the OS
            if ispc
                PosName = strfind(file,'\');
            else
                PosName = strfind(file,'/');
            end
            if strcmp(filename(end-3:end),'.csv')%If csv, gives folder's name
                Name=file(PosName(end-1)+1:PosName(end)-1);
            else%otherwise gives file name
                Name = filename(1:(strfind(filename,'.')-1));%removes file extension
            end
            
            Name = genvarname(Name);% make variable name exportable
            set(obj.handles.IndentGUI,'Name',sprintf(['IndentGUI: ',Name,'\n loaded']));
            assignin('base', Name, obj.handles.data);
            assignin('base','path2file',[path,Name,'.mat']);
            %Save the file so it does not need to be processed anymore
            Stringa=['save(path2file,''',Name,''');'];
            evalin('base',Stringa);
            %save([file(1:PosName(end)),Name],'-struct','handles','data');
            helpdlg('Matlab data were saved in the xls file folder');
            
            
        end
        
        %--------------------------------------------------------------------------
        % MapIndentB_Callback
        %   Open figure with E-modulus map superimposed on picture.
        %   Clickable to select tests.
        %--------------------------------------------------------------------------
        function MapIndentB_Callback(obj, varargin)
            
            %Check if X and Y are present in the file.
            if ~all([any(strcmp('X Test Position',obj.handles.data.rlegend(1,:))) any(strcmp('Y Test Position',obj.handles.data.rlegend(1,:)))])
                errordlg('No position data.');
                return
            elseif xor(any(strcmp('X Test Position',obj.handles.data.rlegend(1,:))),any(strcmp('Y Test Position',obj.handles.data.rlegend(1,:))))
                errordlg('Only Y or X positions have been found. Please recheck your data');
                return
            end
            
            Ecol=cellfun(@(x) strfind(x,'Modulus'),obj.handles.data.rlegend(1,:), 'UniformOutput',0);
            Ecol = ~cellfun(@isempty,Ecol);
            
            Hcol=cellfun(@(x) strfind(x,'Hardness'),obj.handles.data.rlegend(1,:), 'UniformOutput',0);
            Hcol=~cellfun(@isempty,Hcol);
            
            Xcol = strcmpi('X Test Position',obj.handles.data.rlegend(1,:));
            Ycol = strcmpi('Y Test Position',obj.handles.data.rlegend(1,:));
            
            X=obj.handles.data.results(:,Xcol);
            Y=obj.handles.data.results(:,Ycol);
            X=X-min(X);
            Y=Y-min(Y);
            [X,Y]=RotMat(X,Y);
            X=round(X*100)/100;
            Y=round(Y*100)/100;
            [Xsort, iX,iXsort] = unique(X);
            for i=1:length(iX)
                Xsort(i,2)=sum(iXsort(:) == i);
            end
            XofNaN=Xsort((Xsort(:,2)< max(Xsort(:,2))),1);
            
            [Ysort, iY,iYsort] = unique(Y);
            for i=1:length(iY)
                Ysort(i,2)=sum(iYsort(:) == i);
            end
            YofNaN=Ysort((Ysort(:,2)< max(Ysort(:,2))),1);
            
            
            [xq,yq] = meshgrid(Xsort(:,1),Ysort(:,1));
            zq = griddata(X(~isnan(obj.handles.data.results(:,Ecol))),Y(~isnan(obj.handles.data.results(:,Ecol))),obj.handles.data.results(~isnan(obj.handles.data.results(:,Ecol)),Ecol),xq,yq);
            if ~isempty(XofNaN) && ~isempty(YofNaN)
                ZofNaN=zeros(size(zq));
                for i=1:length(XofNaN)
                    for j=1:length(YofNaN)
                        ZofNaN= ZofNaN | (xq==XofNaN(i) & yq==YofNaN(j));
                    end
                end
                zq(ZofNaN)=NaN;
            end
            
            if any(isnan(obj.handles.data.results(:,Ecol)))
                ENaN=find(isnan(obj.handles.data.results(:,Ecol)));
                for i=1:length(ENaN)
                    zq(find(xq==X(ENaN(i)) & yq==Y(ENaN(i))))=NaN;
                end
            end
            
            GUIpos=obj.handles.figPos;%[left,bot,width,height]
            Fig2=figure('Renderer','openGL','Unit','Pixel', 'OuterPosition',[GUIpos(1)+GUIpos(3),GUIpos(2),GUIpos(3),GUIpos(4)]);
            obj.handles.Eaxes=axes('Units','pixels','NextPlot','replacechildren','DeleteFcn',@obj.EaxesDel);
            [~, hMap]=contour(xq,yq,zq,20,'Fill','on','HitTest','off','CDataMapping','scaled','Clipping','on');
            
            hold on
            set(obj.handles.Eaxes,'CLimMode','Manual');
            h = plot(X,Y...
                ,'LineStyle','none',...
                'Marker','v',...
                'MarkerSize',10,...
                'LineWidth',2,...
                'MarkerEdgeColor',[.5 .5 .5],...
                'HitTest','on','Clipping','on');%f
            if ~isempty(obj.handles.Imxy);
                [Ylength, Xlength, ~]=size(obj.handles.imgdata);%x and y data are inversed in img data
                xy=obj.handles.Imxy;
                Xratio= max(X)/(xy(2)-xy(1));%unit conv plot to im
                Yratio= max(Y)/(xy(4)-xy(3));%unit conv plot to im
                
                Xloffset=-xy(1)*Xratio;%left offset
                Xroffset=max(X)+(Xlength-xy(2))*Xratio;%right offset
                Yboffset=-xy(3)*Yratio;%bottom offset
                Ytoffset=max(Y)+(Ylength-xy(4))*Yratio;%top offset
                hIm=image('XData',[Xloffset Xroffset], 'YData',[Yboffset Ytoffset], 'CDataMapping','scaled', 'CData',obj.handles.imgdata);
                uistack(hIm,'bottom');
            end
            Paxes=get(obj.handles.Eaxes,'Position');
            set(Fig2,'Unit','Pixel');Pfig2=get(Fig2,'Position');
            set(obj.handles.Eaxes,'Unit','normalized');
            PaxesNorm=get(obj.handles.Eaxes,'Position');
            Margin=get(obj.handles.Eaxes,'TightInset');
            set(obj.handles.Eaxes,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);
            grid on
            set(obj.handles.Eaxes,'HitTest','on','GridLineStyle','-',...%'Layer','top',
                'XColor',[1 1 1], 'YColor',[1 1 1],'XTick',Xsort(:,1),'YTick',Ysort(:,1),'TickDir','in');
            set(h,'ButtonDownFcn',@obj.Select);
            
            if get(obj.handles.Map3D,'Value')
                MapIndent(obj.handles.data.results(:,Hcol|Xcol|Ycol|Ecol));%Open a new window
            end
            
        end
        
        
        
        %--------------------------------------------------------------------------
        % Select
        %   Activate when clicking on the map to select the tests.
        %--------------------------------------------------------------------------
        function Select(obj, varargin)
            
            hObject=varargin{1};
            hAxes=get(hObject,'Parent');
            set(hAxes,'CLimMode','Manual');
            VX=get(hObject,'XData');
            VX=unique(VX);
            VY=get(hObject,'YData');
            VY=unique(VY);
            dX=min(unique(diff(VX)));
            dY=min(unique(diff(VY)));
            xy1 = round(get(hAxes,'Currentpoint'));
            [d Xp] = min(abs(VX - xy1(1,1)));
            [d Yp] = min(abs(VY - xy1(1,2)));
            x1 = VX(Xp);
            y1 = VY(Yp);
            
            %select axes and check if position is already picked
            axes(hAxes);
            RecPres=findobj(hAxes,'Type','image','XData',[x1-dX/2 x1+dX/2],'YData',[y1-dY/2 y1+dY/2]);
            if ~isempty(RecPres)
                delete(obj.handles.Rec(obj.handles.Rec==RecPres));
                obj.handles.Rec(obj.handles.Rec==RecPres)=[];
                LocMat = (get(hObject,'XData')==x1) & (get(hObject,'YData')==y1);
                TestIndex = find(LocMat);
                Tchoices = get(obj.handles.testlist,'value');
                if any(Tchoices==TestIndex)
                    Tchoices(Tchoices==TestIndex)=[];
                    set(obj.handles.testlist,'value', Tchoices);
                end
            else
                
                hold on;
                RecNumb=length(obj.handles.Rec);
                Rec=image(obj.handles.SelectIm.cdata);
                set(Rec,'AlphaData',obj.handles.SelectIm.alpha,'CDataMapping','scaled','XData',[x1-dX/2 x1+dX/2],'YData',[y1-dY/2 y1+dY/2],'HitTest','off');

                obj.handles.Rec(RecNumb+1)=Rec;
                hold off;
                
                LocMat = (get(hObject,'XData')==x1) & (get(hObject,'YData')==y1);
                TestIndex = find(LocMat);
                Tchoices = get(obj.handles.testlist,'value');
                set(obj.handles.testlist,'value', [Tchoices TestIndex]);
            end
        end
        
        %--------------------------------------------------------------------------
        % EaxesDel
        %   Executes when map axes are deleted
        %--------------------------------------------------------------------------
        function EaxesDel(obj, varargin)
            obj.handles.Eaxes=[];
            obj.handles.Rec=[];
        end
        
        %--------------------------------------------------------------------------
        % editDisp_Callback
        %   Executes when uimenu for editing displacement is selected
        %--------------------------------------------------------------------------
        function editDisp_Callback(obj, varargin)
            if isempty(fieldnames(obj.handles.data))
                warndlg('No data are loaded, please load data','No data');
                return;
            else%if data are loaded, request the user to input min and max displacement.
                prompt = {'Minimum displacement:','Maximum displacement:'};
                dlg_title = 'Displacement range for avering E-modulus and Hardness';
                num_lines = 1;
                def = {'100','200'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                if isempty(answer)
                    return;
                end
            end
            
            Ecol=cellfun(@(x) strfind(x,'Modulus'),obj.handles.data.rlegend(1,:), 'UniformOutput',0);
            Ecol = ~cellfun(@isempty,Ecol);
            
            Hcol=cellfun(@(x) strfind(x,'Hardness'),obj.handles.data.rlegend(1,:), 'UniformOutput',0);
            Hcol=~cellfun(@isempty,Hcol);
            
            DlCol=cellfun(@(x) strfind(x,'Displacement'),obj.handles.data.tlegend(1,:), 'UniformOutput',0);
            DlCol=~cellfun(@isempty,DlCol);
            ElCol=cellfun(@(x) strfind(x,'Modulus'),obj.handles.data.tlegend(1,:), 'UniformOutput',0);
            ElCol=~cellfun(@isempty,ElCol);
            HlCol=cellfun(@(x) strfind(x,'Hardness'),obj.handles.data.tlegend(1,:), 'UniformOutput',0);
            HlCol=~cellfun(@isempty,HlCol);
            MinDis=str2double(answer{1});
            MaxDis=str2double(answer{2});
            if MaxDis<MinDis
                temp=MaxDis;
                MaxDis=MinDis;
                MinDis=temp;
            end
            TestErr=[];
            for i=1:length(obj.handles.data.results(:,Ecol))
                Disp=obj.handles.data.tests{i}(:,DlCol);
                Emod=obj.handles.data.tests{i}(:,ElCol);
                H=obj.handles.data.tests{i}(:,HlCol);
                DispRange=((Disp>=MinDis)&(Disp<=MaxDis));
                
                Eav = mean(Emod(DispRange&~isnan(Emod)));
                Hav = mean(H(DispRange&~isnan(H)));
                if all(DispRange==0) && (~isnan(Eav)||~isnan(Hav))
                    Eav=interp1(Disp,Emod,mean(MinDis,MaxDis));
                    Hav=interp1(Disp,H,mean(MinDis,MaxDis));
                end
                
                if isnan(Eav)||isnan(Hav)%Saves test with no displacement
                    TestErr=[TestErr, i];
                    
                end
                obj.handles.data.results(i,Ecol)=Eav;
                obj.handles.data.results(i,Hcol)=Hav;
            end
            if ~isempty(TestErr)
                ErrText=sprintf('Cannot find data in this displacement range for test(s) %d. They will be defined as NaN',TestErr);
                errordlg(ErrText);
            end
            obj.handles.data.rlegend{1,Ecol}=['Avg Modulus [',num2str(MinDis),'-',num2str(MaxDis),']'];
            obj.handles.data.rlegend{1,Hcol}=['Avg Hardness [',num2str(MinDis),'-',num2str(MaxDis),']'];
        end
        
        %--------------------------------------------------------------------------
        % testlist_Callback
        %   Activate when clicking on the list to plot rectangles on the
        %   map
        %--------------------------------------------------------------------------
        function testlist_Callback(obj, varargin)
            hObject=varargin{1};
            if ~isempty(obj.handles.Eaxes)
                TestChoices=get(hObject,'Value');
                if ishandle(obj.handles.Rec)
                    delete(obj.handles.Rec);
                end;
                obj.handles.Rec=[];
                hIndent=findobj(obj.handles.Eaxes,'Type','Line');
                X=get(hIndent,'XData');
                Y=get(hIndent,'YData');
                dX=min(diff(unique(X)));
                dY=min(diff(unique(Y)));
                axes(obj.handles.Eaxes);
                hold on
                Rec=zeros(length(TestChoices),1);
                
                for i=1:length(TestChoices)
                    Rec(i)=image(obj.handles.SelectIm.cdata,'Parent',obj.handles.Eaxes);
                    set(Rec(i),'AlphaData',obj.handles.SelectIm.alpha,'CDataMapping','scaled','XData',[X(TestChoices(i))-dX/2 X(TestChoices(i))+dX/2],'YData',[Y(TestChoices(i))-dY/2 Y(TestChoices(i))+dY/2],'HitTest','off');
                end
                obj.handles.Rec=Rec;
                hold off
            end
        end
        
        %--------------------------------------------------------------------------
        % Select
        %   Activate when clicking on the map to select the tests.
        %--------------------------------------------------------------------------
        function Table_Callback(obj, varargin)
            a=get(obj.handles.IndentGUI,'Name');a=a(1,:);
            TabWin = figure('Position', [100 200 900 500], 'MenuBar', 'none','Name',sprintf('Table of %s',a), 'NumberTitle','off');
            columnname=obj.handles.data.rlegend(1,:);
            
            t = uitable('Units','normalized','Position',[0 0 1 1],'Data', obj.handles.data.results,'ColumnName', columnname,'RowName',num2str((1:length(obj.handles.data.results))'));
        end
        
        function filtProp_Callback(obj,varargin)
            prompt={'Quadratic fit: minimum depth (nm)',...
                'Quadratic fit: maximum depth (nm)',...
                'Quadratic fit: residual threshold',...
                'Structural compliance: minimum depth (nm)',...
                'Structural compliance: threshold (N*m^{-1})',...
                };
            name='Filter properties';
            numlines=1;
            defaultanswer=cellstr(num2str(obj.handles.filtProp));
            options.Resize='off';
            options.WindowStyle='modal';
            options.Interpreter='tex';
            answer=inputdlg(prompt,name,numlines,defaultanswer,options);
            if isempty(answer)%User clicked cancel
                return
            end
            answer=cellfun(@str2num,answer,'UniformOutput',0);
            if any(cellfun(@isempty,answer))%wrong input
                errH=errordlg('One or several inputs are not numeric. Please input only numerical values.','Non-numeric inputs');
                uiwait(errH);
                obj.filtProp_Callback(obj,varargin);
                return
            end
            answer=cell2mat(answer);
            
            %Changes properties
            obj.handles.filtProp=answer;
        end
        
        %--------------------------------------------------------------------------
        % Analyse_Callback
        %   Filters data. See paper 10.1016/j.msea.2013.11.044 by
        %   Amanieu et al.
        %--------------------------------------------------------------------------
        function filter_Callback(obj, varargin)
            
            if ~all([any(strncmpi('Displacement',obj.handles.data.tlegend(1,:),12)) any(strncmpi('Load',obj.handles.data.tlegend(1,:),4))])
                errordlg('No displacement or load data.');
                return
            end
            % Column indexes for tests
            DispCol = strncmpi('Displacement',obj.handles.data.tlegend(1,:),12);
            LoadCol = strncmpi('Load',obj.handles.data.tlegend(1,:),4);
            EtCol = strncmpi('Modulus',obj.handles.data.tlegend(1,:),7);
            SCol = strncmpi('Harmonic Contact Stiffness',obj.handles.data.tlegend(1,:),25);
            try
                PSSCol = strncmpi('P/(S*S)',obj.handles.data.tlegend(1,:),7);
            catch
            end
            
            % Column indexes in resul matrix
            EoLCol = strncmpi('End Of Loading Marker',obj.handles.data.rlegend(1,:),12);
            SurfCol = strncmpi('Surface Marker',obj.handles.data.rlegend(1,:),12);            
            XCol = strncmpi('X Test Position',obj.handles.data.rlegend(1,:),15);
            YCol = strncmpi('Y Test Position',obj.handles.data.rlegend(1,:),15);            
            ECol=~cellfun(@isempty,strfind(obj.handles.data.rlegend(1,:)','Modulus'));
            HCol=~cellfun(@isempty,strfind(obj.handles.data.rlegend(1,:)','Hardness'));
            
            %Get filter properties
            qDepthMin=obj.handles.filtProp(1);
            qDepthMax=obj.handles.filtProp(2);
            MaxRes=obj.handles.filtProp(3);
            SlopeDepth=obj.handles.filtProp(4);
            SlopeMax=obj.handles.filtProp(5);
            
            
            %Non tagged tests (E-modulus could be measured)
            TestAna=find(~isnan(obj.handles.data.results(:,ECol)));
            %Init for step 1.
            r2=zeros(length(TestAna),1);%initialize residual
            alpha=zeros(length(TestAna),3);%initialize quadratic coeff
            MsgArea=cell(length(TestAna),1); %initialize message (used for debugging)
            
            warning off;
            waitH=waitbar(0,'Step 1: quadratic fit.');
            for i=1:length(TestAna)
                %Displacement and load curves are saved.
                LoadVec = ~isnan(obj.handles.data.tests{TestAna(i)}(:,EtCol));
                Disp=obj.handles.data.tests{TestAna(i)}(LoadVec,DispCol);
                Load=obj.handles.data.tests{TestAna(i)}(LoadVec,LoadCol);
                %quadratic fit
                [r2(i), alpha(i,:)] = SquareFitT( Disp, Load,qDepthMin,qDepthMax);
                MsgArea{i}=['test ', num2str(TestAna(i)),':',' r2=',num2str(r2(i))];%(used for debugging)
                waitbar(i /length(TestAna),waitH,sprintf('Process test # %d/%d',round(i),length(TestAna)));
            end
            warning on;
            
            [r2Sorted, Posr2]=sort(r2);
            close(waitH);
            %%
            %%
            %%%%%%%%%%
            %%Plot the 3 best fits
            %     fig = figure('Name','Analyzed', 'Color',[1 1 1]);
            %     set(fig,'units','normalized','outerposition',[0 0 1 1]);
            %     axes('LineStyleOrder','-|--','ColorOrder',[0,0,1;0,0,1;0,0.5,0;0,0.5,0;1,0,0;1,0,0])
            %     hold all;
            %     PlotLegend=cell(1,6);
            %     for i=1:3;
            %         LoadVec = ~isnan(obj.handles.data.tests{TestAna(Posr2(i))}(:,EtCol));
            %         X=obj.handles.data.tests{TestAna(Posr2(i))}(:,DispCol);
            %         Y=obj.handles.data.tests{TestAna(Posr2(i))}(:,LoadCol);
            % %         plot(X(LoadVec),(Y(LoadVec)-alpha(Posr2(i)).*X(LoadVec).^m(Posr2(i))).^2,'LineWidth',3);
            % %         plot(X(LoadVec),(Y(LoadVec)-mean(Y(LoadVec))).^2,'--','LineWidth',3);
            %         %plot(X(LoadVec),Y(LoadVec)-alpha(Posr2(i)).*X(LoadVec).^m(Posr2(i)),'--','LineWidth',3);
            %         plot(X(:),Y(:),'LineWidth',3);
            %         %plot(X(LoadVec),alpha(Posr2(i)).*X(LoadVec).^m(Posr2(i)),'--','LineWidth',3);
            %         plot(X(LoadVec),polyval(alpha(Posr2(i),:),X(LoadVec)),'--','LineWidth',3);
            %         PlotLegend{1,2*i-1}=['Test ',num2str(TestAna(Posr2(i)),'%03d')];
            %         PlotLegend{1,2*i}=['r2 = ',num2str(r2(Posr2(i)))];
            %     end
            %
            %     xlabel('Displacement into surface (nm)','FontSize',14);
            %     ylabel('Load (mN)','FontSize',14);
            %     set(gca,'FontSize',14,'LineWidth',1.5);
            %     hleg1=legend(PlotLegend);
            %     set(hleg1,'Location','NorthWest');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%
            
            
            TestAnaLvD=TestAna(Posr2(r2Sorted<MaxRes & alpha(Posr2(:),1)>0& alpha(Posr2(:),2)>0));
            %Next step of method -- Check the consistency of the slope of P/S�
            if ~PSSCol
                errordlg('No load over squared stiffness data, analysis will stop at step 1.')
                %Save how many steps the test passed.
                if ~any(strcmp(obj.handles.data.rlegend,'Filter step'))
                    obj.handles.data.rlegend{1,end+1}='Filter step';
                    obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
                end
                FiltCol=strcmpi('Filter step',obj.handles.data.rlegend(1,:));
                obj.handles.data.results(:,FiltCol)=nan(size(obj.handles.data.results(:,FiltCol),1),1);
                obj.handles.data.results(TestAna,FiltCol)=zeros(size(obj.handles.data.results(TestAna,FiltCol),1),1);
                obj.handles.data.results(TestAnaLvD,FiltCol)=ones(size(obj.handles.data.results(TestAnaLvD,FiltCol),1),1);
                % Save residual
                if ~any(strcmp(obj.handles.data.rlegend,'Residual'))
                    obj.handles.data.rlegend{1,end+1}='Residual';
                    obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
                end
                ResCol=strcmpi('Residual',obj.handles.data.rlegend(1,:));
                obj.handles.data.results(:,ResCol)=nan(size(obj.handles.data.results,1),1);
                obj.handles.data.results(TestAna,ResCol)=r2;
                
                %Save structural compliance
                if ~any(strcmp(obj.handles.data.rlegend,'Cs'))
                    obj.handles.data.rlegend{1,end+1}='Cs';
                    obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
                end
                CsCol=strcmpi('Cs',obj.handles.data.rlegend(1,:));
                obj.handles.data.results(:,CsCol)=nan(size(obj.handles.data.results,1),1);
                return
            end
            
            
            pSlope=zeros(length(TestAna),2);
            for i=1:length(TestAna)
                try
                    Disp=obj.handles.data.tests{TestAna(i)}(:,DispCol);
                catch
                    S=sprintf('error at step %d for test %d on PSS data',i,TestAna(i));
                    errordlg(S);
                end
                %% definition of the SYS factor (see jakes et al 2008 and 2009
                % DOI: 10.1557/JMR.2008.0131, DOI: 10.1557/JMR.2009.0076)
                PSS=obj.handles.data.tests{TestAna(i)}(:,PSSCol)./1000;%convertion to 1/Pa
                PSStemp=PSS(~isnan(PSS)&Disp>SlopeDepth);
                L=obj.handles.data.tests{TestAna(i)}(:,LoadCol)./1000;%convertion to N
                L=L(~isnan(PSS)&Disp>SlopeDepth);
                sqPSS=sqrt(PSStemp);% Y axis of SYS plot - compliance times square root of load
                sqL=sqrt(L);% X axis of SYS plot - square root of load
                try
                    pSlope(i,1:2)=polyfit(sqL,sqPSS,1);
                catch
                    S=sprintf('error at step %d for test %d on PSS data',i,TestAna(i));
                    errordlg(S);
                end
            end
            TestAnaCs=TestAna(pSlope(:,1)<SlopeMax);
            assignin('base', 'AnalysedTests',[TestAna(Posr2(:)),r2Sorted,obj.handles.data.results(TestAna(Posr2(:)),ECol),alpha(Posr2(:),1),alpha(Posr2(:),2),alpha(Posr2(:),3),pSlope(Posr2(:),1)]);
            TestAnaOut=intersect(TestAnaCs,TestAnaLvD);
            [OutputEModul, Pos]=sort(obj.handles.data.results(TestAnaOut,ECol));
            OutputTests=TestAnaOut(Pos);
            Cs=pSlope(pSlope(:,1)<SlopeMax,1);
            Cs=Cs(Pos);
            OutputH=obj.handles.data.results(OutputTests,HCol);
            X=obj.handles.data.results(OutputTests,XCol);
            Y=obj.handles.data.results(OutputTests,YCol);
            assignin('base', 'OutputTests',[OutputTests,OutputEModul,OutputH, Cs,X,Y]);
            %% Save filter results in the "result".
            %Passed filter 1 (Load vs Displacement)?
            if ~any(strcmp(obj.handles.data.rlegend,'Filter LvD'))
                obj.handles.data.rlegend{1,end+1}='Filter LvD';
                obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
            end 
            FiltLvDCol=strcmpi('Filter LvD',obj.handles.data.rlegend(1,:));
            obj.handles.data.results(:,FiltLvDCol)=nan(size(obj.handles.data.results(:,FiltLvDCol),1),1);
            obj.handles.data.results(TestAna,FiltLvDCol)=zeros(size(obj.handles.data.results(TestAna,FiltLvDCol),1),1);
            obj.handles.data.results(TestAnaLvD,FiltLvDCol)=ones(size(obj.handles.data.results(TestAnaLvD,FiltLvDCol),1),1);
            
            %Passed filter 2 (Load over Squared Stiffness)?
            if ~any(strcmp(obj.handles.data.rlegend,'Filter Cs'))
                obj.handles.data.rlegend{1,end+1}='Filter Cs';
                obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
            end 
            FiltCsCol=strcmpi('Filter Cs',obj.handles.data.rlegend(1,:));
            obj.handles.data.results(:,FiltCsCol)=nan(size(obj.handles.data.results(:,FiltCsCol),1),1);
            obj.handles.data.results(TestAna,FiltCsCol)=zeros(size(obj.handles.data.results(TestAna,FiltCsCol),1),1);            
            obj.handles.data.results(TestAnaCs,FiltCsCol)=ones(size(obj.handles.data.results(TestAnaCs,FiltCsCol),1),1);
            
            % Save residual
            if ~any(strcmp(obj.handles.data.rlegend,'Residual'))
                obj.handles.data.rlegend{1,end+1}='Residual';
                obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
            end
            ResCol=strcmpi('Residual',obj.handles.data.rlegend(1,:));
            obj.handles.data.results(:,ResCol)=nan(size(obj.handles.data.results,1),1);
            obj.handles.data.results(TestAna,ResCol)=r2;
            
            %Save structural compliance
            if ~any(strcmp(obj.handles.data.rlegend,'Cs'))
                obj.handles.data.rlegend{1,end+1}='Cs';
                obj.handles.data.results(:,end+1)=nan(size(obj.handles.data.results,1),1);
            end
            CsCol=strcmpi('Cs',obj.handles.data.rlegend(1,:));
            obj.handles.data.results(:,CsCol)=nan(size(obj.handles.data.results,1),1);
            obj.handles.data.results(TestAna,CsCol)=pSlope(:,1);
            
            %%No use of polynomial coeff. for now. Might be implemented
            %%later.
            %             if ~any(strcmp(obj.handles.data.rlegend,'Polynomial coeff.'))
            %                 obj.handles.data.rlegend{1,end+1}='Polynomial coeff.';
            %             end
        end
        
        
        
        %--------------------------------------------------------------------------
        % transparency_Callback
        %   adjust transparency of map to see image in the background.
        %--------------------------------------------------------------------------
        function transparency_Callback(obj, varargin)
            hObject=varargin{1};
            if ~isempty(obj.handles.Eaxes);
                hMap = findobj(obj.handles.Eaxes,'Type','hggroup');
                hLines = get(hMap,'Children');
                set(hLines,'FaceAlpha',1-get(hObject,'Value'));
            end
            
        end
        
        
        
        %--------------------------------------------------------------------------
        % ImageCali_Callback
        %   Calibrate one color jpg, bmp or png image with plot.
        %--------------------------------------------------------------------------
        function ImageCali_Callback(obj, varargin)

            imf  = imformats;
            exts = lower([imf.ext]);
            exts_str = sprintf('*.%s;', exts{:}); exts_str(end) = '';
            [filename, path, c] = uigetfile(exts_str,'Select image file',obj.handles.lastDir);
            imgdata=importdata([path,filename]);
            
            %rotates data
            imgdataRGB = rotAng(imgdata);
            figure('Unit','Pixel','Name','Select your first and last indent','NumberTitle','off', 'MenuBar','none',...
                'ToolBar','none');
            image('CData',imgdataRGB);
            xy=ginput(2);
            obj.handles.Imxy=xy;
            obj.handles.imgdata=imgdataRGB;
            
        end
            
        function Deconvolution(obj, varargin)
            
            if isempty(fieldnames(obj.handles.data))
                errordlg('No data are loaded, please load data','No data');
                return;
            end
            if ~any(strcmp(obj.handles.data.rlegend,'Filter LvD'))
                errordlg('Data not filtered.')
                return
            end
            
            GUIpos=get(obj.handles.IndentGUI,'Position');%[left,bot,width,height]
            
            PropH = dialog('Name','Deconvolution settings',...
                'Position', [GUIpos(1)+GUIpos(3)-100, GUIpos(2)+GUIpos(4)-100, 200, 200],...
                'WindowStyle','normal');
            
            prompt={'Filter Steps passed',...
                'Statistical analysis',...
                'Plot figure?',...
                };
            StrFilt={'No filter',...
                'quadratic Load vs Disp',...
                'Joslin-Oliver Parameter'...
                };
            StrGauss={'Simple average',...
                '2 gaussian sigmoids',...
                '3 gaussian sigmoids',...
                '4 gaussian sigmoids'...
                };
            StrPlot={'Yes',...
                'No',...
                };
            PlotTxtH=uicontrol(PropH    , ...
                'Style'      , 'text',...
                'Position'   ,[10, 172, 180, 16], ...
                'String'     ,prompt{3}          , ...
                'FontSize'   ,9,...
                'FontWeight','bold',...
                'Tag'        ,'Filttxt'                 ...
                );
            PlotH=uicontrol(PropH    , ...
                'Style'      , 'popup',...
                'Position'   ,[10, 150, 180, 20], ...
                'String'     ,StrPlot          , ...
                'Value'      ,2,...
                'Tag'        ,'Filt'                 ...
                );
            FiltTxtH=uicontrol(PropH    , ...
                'Style'      , 'text',...
                'Position'   ,[10, 122, 180, 16], ...
                'String'     ,prompt{1}          , ...
                'FontSize'   ,9,...
                'FontWeight','bold',...
                'Tag'        ,'Filttxt'                 ...
                );
            FiltH=uicontrol(PropH    , ...
                'Style'      , 'popup',...
                'Position'   ,[10, 100, 180, 20], ...
                'String'     ,StrFilt          , ...
                'Value'      ,3,...
                'Tag'        ,'Filt'                 ...
                );
            GaussTxtH=uicontrol(PropH    , ...
                'Style'      , 'text',...
                'Position'   ,[10, 72, 180, 16], ...
                'String'     ,prompt{2}          , ...
                'FontSize'   ,9,...
                'FontWeight','bold',...
                'Tag'        ,'Gausstxt'                 ...
                );
            GaussH=uicontrol(PropH    , ...
                'Style'      , 'popup',...
                'Position'   ,[10, 50, 180, 20], ...
                'String'     ,StrGauss, ...
                'Value'      ,2,...
                'Tag'        ,'Gauss'                 ...
                );
            OkB=uicontrol(PropH,...
                'Style','pushbutton',...
                'Position'   ,[10, 10, 70, 30], ...
                'String','OK',...
                'Callback',{@close_dec,PropH,1}...
                );
            CancelB=uicontrol(PropH,...
                'Style','pushbutton',...
                'Position'   ,[90, 10, 70, 30], ...
                'String','Cancel',...
                'Callback',{@close_dec,PropH,0}...
                );
            uiwait(PropH);
            if ishandle(PropH)%Check if dialog still exists ( not cancelled)
                FiltStep=get(FiltH,'Value');
                nGauss=get(GaussH,'Value');
                PlotYN=get(PlotH,'Value');
                disp(['nGauss: ',num2str(nGauss)]);
                close(PropH);
            else
                return
            end
            FiltCol1=strcmpi('Filter LvD',obj.handles.data.rlegend(1,:));
            FiltCol2=strcmpi('Filter Cs',obj.handles.data.rlegend(1,:));
            ECol=~cellfun(@isempty,strfind(obj.handles.data.rlegend(1,:)','Modulus'));
            HCol=~cellfun(@isempty,strfind(obj.handles.data.rlegend(1,:)','Hardness'));
            FiltSteps=obj.handles.data.results(:,FiltCol1)+obj.handles.data.results(:,FiltCol2);
            
            switch FiltStep
                case 1 %No filter
                    FiltTest=FiltSteps==0;
                case 2 %quadratic Load vs Displacement
                    FiltTest=FiltSteps==1;
                case 3 %Joslin-Oliver filter
                    FiltTest=FiltSteps==2;
                otherwise
                    errordlg('Please enter a valid number of steps');
                    return
            end
            EProp=obj.handles.data.results(FiltTest,ECol);
            HProp=obj.handles.data.results(FiltTest,HCol);            
            EProp=sort(EProp);
            HProp=sort(HProp);
            
            %If sigmoid fit, check if user has Curve Fitting Toolbox.
            if ~license('checkout','curve_fitting_toolbox') && nGauss~=1
                errordlg('You require the curve fitting toolbox. A simple average will be made.');
                nGauss=1;
            end
            switch nGauss
                case 1
                    stat_ana.E.mean=mean(EProp);
                    stat_ana.E.std=std(EProp);
                    stat_ana.H.mean=mean(HProp);
                    stat_ana.H.std=std(HProp);
                    stat_ana.type='Simple average';
                otherwise                  
                    [fitresult, gof]=SigFit(EProp, nGauss);
                    stat_ana.E.fitresult=fitresult;
                    stat_ana.E.gof=gof;
                    [fitresult, gof]=SigFit(HProp, nGauss);
                    stat_ana.H.fitresult=fitresult;
                    stat_ana.H.gof=gof;
                    
                    switch PlotYN
                        case 1 %Yes
                            ReadSigFit(stat_ana.E.fitresult,EProp,'E-modulus (GPa)');
                            ReadSigFit(stat_ana.H.fitresult,HProp,'Hardness (GPa)');
                        case 2 %No
                    end
                    stat_ana.type=[num2str(nGauss),' Sigmoids'];
            end
            obj.handles.data.stat_ana=stat_ana;
            
            
            
        end
        
    end
end

%Rotate image
function [imgdataout] = rotAng(imgdata)
if isstruct(imgdata)
    imgdata=imgdata.cdata;
end
[L C RGB]=size(imgdata);
k = inputdlg('rotate image by k*90�, k = ');
k = str2double(k{1});
k=k+2;
if (k==3)||(k==5)
    imgdataout=zeros([C L RGB]);
    for i=1:RGB
        imgdataout(:,:,i)=rot90(fliplr(imgdata(:,:,i)),k);
    end
elseif (k==6)||(k==2)||(k==4)
    imgdataout=zeros([L C RGB]);
    for i=1:RGB
        imgdataout(:,:,i)=rot90(fliplr(imgdata(:,:,i)),k);
    end
else
    herr=errordlg('Please enter a single integer between 0 and 3');
    uiwait(herr);
    imgdataout=rotAng(imgdata);
end
imgdataout=uint8(imgdataout);
end




function close_dec(varargin)
Status = varargin{4};
DialogH=varargin{3};
if Status
    uiresume(DialogH);
else
    close(DialogH);
end


end


%--------------------------------------------------------------------------
% helpBtnCallback
%   This opens up a help dialog box
%--------------------------------------------------------------------------
function help_Callback(varargin)

helpdlg({...
    'tba'}, ...
    'Help');
end

%--------------------------------------------------------------------------
% helpBtnCallback
%   This opens up an about dialog box
%--------------------------------------------------------------------------
function about_Callback(varargin)
S = sprintf('This app was developped by H-Y Amanieu and is licensed under the Apache license 2.0. \nNeed help or improvements? Feel free to contact me at hy@dataseed.co ');
helpdlg({...
    S}, ...
    'About');
end