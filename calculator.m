function varargout = calculator(varargin)
% CALCULATOR MATLAB code for calculator.fig
%      CALCULATOR, by itself, creates a new CALCULATOR or raises the existing
%      singleton*.
%
%      H = CALCULATOR returns the handle to a new CALCULATOR or the handle to
%      the existing singleton*.
%
%      CALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALCULATOR.M with the given input arguments.
%
%      CALCULATOR('Property','Value',...) creates a new CALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calculator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calculator

% Last Modified by GUIDE v2.5 25-Apr-2018 15:23:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @calculator_OpeningFcn, ...
    'gui_OutputFcn',  @calculator_OutputFcn, ...
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

% --- Executes just before calculator is made visible.
function calculator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calculator (see VARARGIN)

% Choose default command line output for calculator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calculator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = calculator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_calculate.
function pushbutton_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global n2 n4 n8 n16 n32 n64

t_conm = str2double(get(handles.edit_conm, 'String'));
% BW_tx = str2double(get(handles.edit_bw_tx, 'String'));
P_tx = str2double(get(handles.edit_pt, 'String'));
P_sat = str2double(get(handles.edit_sat, 'String'));
P_sen = str2double(get(handles.edit_sen, 'String'));
BW_rx = str2double(get(handles.edit_bw_rx, 'String'));
M = str2double(get(handles.edit_margin, 'String'));
Pen = str2double(get(handles.edit_pen, 'String'));
alpha = str2double(get(handles.edit_att, 'String'));
L_add = str2double(get(handles.edit_add_loss, 'String'));
D = str2double(get(handles.edit_disp, 'String'))*1e-6; % s/m^2
lambda = str2double(get(handles.edit_lambda, 'String'));
rate = str2double(get(handles.edit_rate, 'String'));
n2 = str2double(get(handles.edit_n2, 'String'));
n4 = str2double(get(handles.edit_n4, 'String'));
n8 = str2double(get(handles.edit_n8, 'String'));
n16 = str2double(get(handles.edit_n16, 'String'));
n32 = str2double(get(handles.edit_n32, 'String'));
n64 = str2double(get(handles.edit_n64, 'String'));
rz = str2double(get(handles.radiobutton_rz, 'Value'));
% nrz = str2double(get(handles.radiobutton_nrz, 'Value'));
n_edfas = str2double(get(handles.edit_n_edfas, 'String'));

% Splitter losses
L2 = 5.1;
L4 = 8.4;
L8 = 11.9;
L16 = 15.5;
L32 = 18.8;
L64 = 20.3;

% EDFA gain
EDFAs = n_edfas*28;

L_splitters = L2*n2 + L4*n4 + L8*n8 + L16*n16 + L32*n32 + L64*n64;

% Lengths limited by power
L_max = (P_tx + EDFAs - L_add - L_splitters - P_sen - M - Pen)/alpha;
L_min = (P_tx + EDFAs - L_add - L_splitters - P_sat - M - Pen)/alpha;
if L_min < 0
    L_min = 0;
end

set(handles.text_lmax, 'String', num2str(L_max));
set(handles.text_lmin, 'String', num2str(L_min));

% Limitations by time
if rz == 1
    k = 0.35;
else
    k = 0.7;
end

t_sys_max_2 = (k/(rate*1e6))^2; % s^2

sigma_f = rate*1e6/2; % Hz
sigma_lambda = (((lambda*1e-9)^2)/3e8)*sigma_f; % s
trx_2 = (0.350/(BW_rx*1e6))^2; % s^2
ttx_2 = (t_conm*1e-9)^2; % s^2
t_total_2 = t_sys_max_2 - ttx_2 - trx_2; % s^2
L_max_disp = sqrt(t_total_2)/(D*sigma_lambda)/1000; % km

set(handles.text_lmax_disp, 'String', num2str(L_max_disp));

% Conclusions
if L_max > L_max_disp
    concl = 'Dispersion limits the link.';
else
    concl = 'Power limits the link.';
end

if (L_max>20 && L_max_disp>20)
    concl = [concl newline 'The maximum distance is greater than 20 km.'];
else
    concl = [concl newline 'The link does not reach the limit of 20 km.'];
end

set(handles.text_concl, 'String', concl);

% --- Executes on button press in pushbutton_ntotal.
function pushbutton_ntotal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ntotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n2 n4 n8 n16 n32 n64

n2 = str2double(get(handles.edit_n2, 'String'));
n4 = str2double(get(handles.edit_n4, 'String'));
n8 = str2double(get(handles.edit_n8, 'String'));
n16 = str2double(get(handles.edit_n16, 'String'));
n32 = str2double(get(handles.edit_n32, 'String'));
n64 = str2double(get(handles.edit_n64, 'String'));

Nusers = n2*2 + n4*4 + n8*8 + n16*16 + n32*32 + n64*64;
set(handles.text_users, 'String', num2str(Nusers));

function edit_n2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n2 as text
%        str2double(get(hObject,'String')) returns contents of edit_n2 as a double

function edit_n4_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n4 as text
%        str2double(get(hObject,'String')) returns contents of edit_n4 as a double

function edit_n8_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n8 as text
%        str2double(get(hObject,'String')) returns contents of edit_n8 as a double

function edit_n16_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n16 as text
%        str2double(get(hObject,'String')) returns contents of edit_n16 as a double

function edit_n32_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n32 as text
%        str2double(get(hObject,'String')) returns contents of edit_n32 as a double

function edit_n64_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n64 as text
%        str2double(get(hObject,'String')) returns contents of edit_n64 as a double

function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double

function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double

function edit_att_Callback(hObject, eventdata, handles)
% hObject    handle to edit_att (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_att as text
%        str2double(get(hObject,'String')) returns contents of edit_att as a double

function edit_add_loss_Callback(hObject, eventdata, handles)
% hObject    handle to edit_add_loss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_add_loss as text
%        str2double(get(hObject,'String')) returns contents of edit_add_loss as a double

function edit_disp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_disp as text
%        str2double(get(hObject,'String')) returns contents of edit_disp as a double

function edit_rate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rate as text
%        str2double(get(hObject,'String')) returns contents of edit_rate as a double

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

function edit_sat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sat as text
%        str2double(get(hObject,'String')) returns contents of edit_sat as a double


function edit_sen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sen as text
%        str2double(get(hObject,'String')) returns contents of edit_sen as a double

function edit_bw_rx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bw_rx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bw_rx as text
%        str2double(get(hObject,'String')) returns contents of edit_bw_rx as a double

function edit_margin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin as text
%        str2double(get(hObject,'String')) returns contents of edit_margin as a double

function edit_pen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pen as text
%        str2double(get(hObject,'String')) returns contents of edit_pen as a double

function edit_conm_Callback(hObject, eventdata, handles)
% hObject    handle to edit_conm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_conm as text
%        str2double(get(hObject,'String')) returns contents of edit_conm as a double


function edit_bw_tx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bw_tx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bw_tx as text
%        str2double(get(hObject,'String')) returns contents of edit_bw_tx as a double

function edit_pt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pt as text
%        str2double(get(hObject,'String')) returns contents of edit_pt as a double


function edit_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_lambda as a double

function edit_n_edfas_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n_edfas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n_edfas as text
%        str2double(get(hObject,'String')) returns contents of edit_n_edfas as a double

% --- Executes during object creation, after setting all properties.
function edit_pt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n64_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_att_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_att (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_add_loss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_add_loss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_sat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_margin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_pen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_conm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_conm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_bw_tx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bw_tx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_bw_rx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bw_rx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_sen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_n_edfas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n_edfas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
