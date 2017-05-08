function varargout = nucleus(varargin)
% NUCLEUS MATLAB code for nucleus.fig
%      NUCLEUS, by itself, creates a new NUCLEUS or raises the existing
%      singleton*.
%
%      H = NUCLEUS returns the handle to a new NUCLEUS or the handle to
%      the existing singleton*.
%
%      NUCLEUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUCLEUS.M with the given input arguments.
%
%      NUCLEUS('Property','Value',...) creates a new NUCLEUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nucleus_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nucleus_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nucleus

% Last Modified by GUIDE v2.5 28-Mar-2017 14:38:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nucleus_OpeningFcn, ...
                   'gui_OutputFcn',  @nucleus_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nucleus is made visible.
function nucleus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nucleus (see VARARGIN)

% Choose default command line output for nucleus
handles.output = hObject;
handles.mipGFP = {};
handles.final = {};
handles.temp = {};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nucleus wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nucleus_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gfp;
global rfp;
global trans;

% GFP, RFP, Trans
gfp = bfopen();
rfp = bfopen();
trans = bfopen();

% Grab the first slice
gfp = gfp{1};
rfp = rfp{1};
trans = trans{1};

% Get the data ready for the whole GUI
handles.gfp = gfp;
handles.rfp = rfp;
handles.trans = trans;

handles.rows = size(gfp, 1);
handles.cols = size(gfp, 2);
disp(strcat('*** Assigned ', int2str(handles.rows), ' and ', int2str(handles.cols), ' for the size***'));

% Grab MIP of GFP, 
mipGFP = zeros(size(gfp{1}, 1), size(gfp{1}, 2), 7);
mipRFP = mipGFP;
for i = 1:7
   mipGFP(:, :, i) = gfp{i}; 
   mipRFP(:, :, i) = rfp{i};
end

mipGFP = max(mipGFP, [], 3);
mipRFP = max(mipRFP, [], 3);

disp('***size of mipRFP: ');
disp(size(mipRFP));
disp('***size of mipGFP: ');
disp(size(mipGFP));

% Create RGB stack, s
s = zeros(size(mipGFP, 1), size(mipGFP, 2), 3);
s(:, :, 1)=mat2gray(mipRFP)*2;
s(:, :, 2)=mat2gray(mipGFP); 
s(:, :, 3)=mat2gray(trans{1});

% Assign mipGFP to first position in the cell in case we need it later
handles.mipGFP{1} = mipGFP;

% Plot RGB in axes 1 (left)
axes(handles.axes1);
imshow(s, []);

% Set slider to proper min, max and step
% We are collapsing a stack of seven into a single MIP, so there ought to
% be (number of stacks) / 7 steps in the slider
set(handles.slider1, 'SliderStep', [7/length(gfp) 7/length(gfp)],...
    'Min', 1, 'Max', length(gfp)/7, 'Value', 1);

guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current position of slider/image stack
pos = ceil(get(handles.slider1,'Value'));
axes(handles.axes1);

% Make empty matrix to populate with the maximum intensity projections for
% both GFP and RFP
mipGFP = zeros(handles.rows, handles.cols, 7);
mipRFP = mipGFP;

% Create maximum intensity projection for GFP and RFP
for i = 1:7
   idx = (pos - 1)*7 + i; 
   mipGFP(:, :, i) = handles.gfp{idx};
   mipRFP(:, :, i) = handles.rfp{idx};
end

mipGFP = max(mipGFP, [], 3);
mipRFP = max(mipRFP, [], 3);

% Make stack again for another RGB stack
s = zeros(handles.rows, handles.cols, 3);
s(:, :, 1)=mat2gray(mipRFP)*2;
s(:, :, 2)=mat2gray(mipGFP); 
s(:, :, 3)=mat2gray(handles.trans{pos});

% Populate handles with the mipgFP
handles.mipGFP{pos} = mipGFP;

% Show it on axes 1
axes(handles.axes1);
imshow(s, []);

% Show the naked trans on axes 2
axes(handles.axes2);
imshow(handles.trans{pos}, []);

% Clear temporary data so it's ready to analyze the current slice
handles.temp = {};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
%% GET RECTANGLE
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get mins and maxes for the crop
slice = ceil(get(handles.slider1,'Value'));

disp('***ON SLICE***');
disp(slice);

% User select rectangle
axes(handles.axes1);
rect = getrect;
disp(rect);

xmin = rect(1); xmax = rect(1) + rect(3);
ymin = rect(2); ymax = rect(2) + rect(4);

axes(handles.axes2);
disp(size(handles.mipGFP{slice}(ymin:ymax, xmin:xmax)));
imshow(imbinarize(mat2gray(handles.mipGFP{slice}(ymin:ymax, xmin:xmax))), []);

% Get handles.temp and don't add them to handles permanent until we have
% decided to commit
idx = length(handles.temp) + 1;
% handles.temp{idx} = {slice, handles.mipGFP{slice}(ymin:ymax, xmin:xmax)};
addition = {slice, handles.mipGFP{slice}(ymin:ymax, xmin:xmax)};
handles.temp = [handles.temp; addition];

disp('***INFO: handles.temp is now: ***');
disp(handles.temp);


guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
%% COMMIT DATA
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add temp to data
idx = length(handles.final) + 1;
handles.final = [handles.final; handles.temp];

% Clear temp
handles.temp = {};

% Display success message
[x,map]=imread('http://www.abc.net.au/news/image/7197728-3x2-940x627.jpg', 'jpg');
axes(handles.axes2);
imshow(x);

disp('***INFO: handles.final is now: ***');
disp(handles.final);

guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%% SAVE EVERYTHING
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

name = inputdlg;
data = handles.final;
save(name{1}, 'data');

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'r' % get rectangle
        pushbutton3_Callback(hObject, [], handles);
    case 'c' % commit
        pushbutton4_Callback(hObject, [], handles);
end
