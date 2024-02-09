function varargout = lab9(varargin)
% LAB9 MATLAB code for lab9.fig
%      LAB9, by itself, creates a new LAB9 or raises the existing
%      singleton*.
%
%      H = LAB9 returns the handle to a new LAB9 or the handle to
%      the existing singleton*.
%
%      LAB9('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAB9.M with the given input arguments.
%
%      LAB9('Property','Value',...) creates a new LAB9 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lab9_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lab9_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lab9

% Last Modified by GUIDE v2.5 13-Dec-2017 21:54:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab9_OpeningFcn, ...
                   'gui_OutputFcn',  @lab9_OutputFcn, ...
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


% --- Executes just before lab9 is made visible.
function lab9_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lab9 (see VARARGIN)

% Choose default command line output for lab9
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lab9 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lab9_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% in handles.data , there are several field
% v: the handle of the highlight square
% square_size : the size of the square ; default is 10
% k: storing the array of the picture showing now
% pt: storing the position user clicking, pt=0 means no clicking occur
% width : the width of the picture, storing the most left and most right of
% the picture(using this to check whether user click out ot the picture)
% hiught : similar as width, but store the most up and down of the picture
%rate: store the rate that the picture been compressed



% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirpath = uigetdir('D:\орн▒\'); 
list = dir([dirpath '\*.jpg']);  % read all the jpg file in the directory
handles.data.path = dirpath; 
handles.data.list=list;
if length(handles.data.list) == 1  % if only 1 picture, turn off the sliderbar
    set(handles.bar,'enable','off');
else
    % set the sliderstrp , move by 1 no metter using < and > or mouse 
    set(handles.bar,'enable','on');
    set(handles.bar,'min',1,'max',length(handles.data.list), 'value', 1 ,'SliderStep' , [1/(length(handles.data.list)-1),1/(length(handles.data.list)-1)]);
    
end
% using pixel as unit
set(handles.pic,'units','pixels');
set(handles.highlightpic,'units','pixels');

c = imread([dirpath '\' list(1).name]);
[c rate] = adjust(c);
set(handles.info,'string',['Picture'  ' 1'   ' of' int2str(length(handles.data.list)) '  ' list(1).name '  '  int2str(size(c,1)) ' * '  int2str(size(c,2)) ' @'  int2str(rate*100) '%' ]);
[c,width,height]=put_center(c);
imshow(c,'parent',handles.pic);
handles.data.v=0;
handles.data.square_size=10;
handles.data.pt = 0;
handles.data.k = c;
hold(handles.pic,'on');
handles.data.width = width;
handles.data.height = height;
handles.data.rate = rate;
menulist = get(handles.menu,'string');
% if the path is not in pop up menu , then add it into the menulist and show the path, else show the path only 
if sum(strcmp(dirpath,menulist))~=1
    menulist{end+1} = dirpath;
    set(handles.menu,'string',menulist);
    set(handles.menu,'value',length(menulist));
else
    a=find(strcmp(dirpath,menulist)==1);
    set(handles.menu,'value',a);
end

% store data in handles.data
guidata(hObject,handles);


% --- Executes on selection change in menu.
function menu_Callback(hObject, eventdata, handles)
% hObject    handle to menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu

% get the path of directory user select
dirpath = get(hObject,'string');

index=get(hObject,'value');
list = dir([dirpath{index} '\*.jpg']);
handles.data.path = dirpath{index};
handles.data.list=list;
% if only 1 picture in the folder , than canceal the sliderbar
if length(handles.data.list) == 1 
    set(handles.bar,'enable','off');
else 
    set(handles.bar,'enable','on');
    set(handles.bar,'min',1,'max',length(handles.data.list), 'value', 1 ,'SliderStep' , [1/(length(handles.data.list)-1),1/(length(handles.data.list)-1)]);
end

set(handles.pic,'units','pixels');
set(handles.highlightpic,'units','pixels');

c = imread([dirpath{index} '\' list(1).name]);
[c rate] = adjust(c);
set(handles.info,'string',['Picture'  ' 1'   ' of' int2str(length(handles.data.list)) '  ' list(1).name ' ' int2str(size(c,1)) ' * '  int2str(size(c,2)) ' @'  int2str(rate*100) '%' ]);
[c,width,height]=put_center(c);
imshow(c,'parent',handles.pic);
handles.data.v=0;
handles.data.square_size=10;
handles.data.pt = 0;
handles.data.k = c;
hold(handles.pic,'on');
handles.data.width = width;
handles.data.height = height;
handles.data.rate = rate;


guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'string',{'D:\орн▒\testfile' }); 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end


% --- Executes on button press in up.
function up_Callback(hObject, eventdata, handles)
% hObject    handle to up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check whether there is a highlight square on the screen , if not , do
% nothing
if handles.data.pt ~= 0
    % check whether the center will be out of the picture
if handles.data.pt(2)-5 > handles.data.height(1)
    % check whether the upside of the square will exceed the figure
    if handles.data.pt(2)-5-handles.data.square_size >0
        % move the center of hoghlight square on by 5
    handles.data.pt(2) = handles.data.pt(2) - 5 ;
    pt = handles.data.pt;
    k=handles.data.k;
    % read the region user want to highlight
    e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
    e=imresize(e,2);
    % show on the highlight picture on the square(i,e, highlightpic)
    imshow(e,'parent',handles.highlightpic);  
    % plot the square on the picture
    set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
    set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);

    guidata(hObject,handles);
    end
end
end

% --- Executes on button press in down.
function down_Callback(hObject, eventdata, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% similar as up 


if handles.data.pt ~= 0
    if handles.data.pt(2)+5 <= handles.data.height(2)
        if handles.data.pt(2)+5+handles.data.square_size < size(handles.data.k , 1)
            handles.data.pt(2) = handles.data.pt(2) + 5 ;
            pt = handles.data.pt;

            k=handles.data.k;
            e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
            e=imresize(e,2);
   
            imshow(e,'parent',handles.highlightpic);  
            set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
            set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);

            guidata(hObject,handles);
        end
    end
end
% --- Executes on button press in right.
function right_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.data.pt ~= 0
    if handles.data.pt(1)+5 <= handles.data.width(2) 
        if handles.data.pt(1)+handles.data.square_size+5 < size(handles.data.k,2)
            handles.data.pt(1) = handles.data.pt(1) + 5 ;
            pt = handles.data.pt;

            k=handles.data.k;
   
            e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
            e=imresize(e,2);
   
            imshow(e,'parent',handles.highlightpic);  
            set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
            set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);

            guidata(hObject,handles);
    
        end
    end
end

% --- Executes on button press in left.
function left_Callback(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.data.pt ~= 0
    if handles.data.pt(1)-5 > handles.data.width(1)
        if handles.data.pt(1)-handles.data.square_size-5 > 0
            handles.data.pt(1) = handles.data.pt(1) - 5 ;
            pt = handles.data.pt;

            k=handles.data.k;
            e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
            e=imresize(e,2);
    
            imshow(e,'parent',handles.highlightpic);  
            set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
            set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);
            guidata(hObject,handles);
        end
    end

end

% --- Executes on button press in plus.
function plus_Callback(hObject, eventdata, handles)
% hObject    handle to plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get the current point and the current size from the handles.data


pt = handles.data.pt;
x = handles.data.square_size;
k=handles.data.k;
% check whether there is the hihglight region, if no , do nothing
if pt ~=0
    % check whether the square will exceed the figure 
    if pt(1)+x+2 < size(k,2) && pt(1)-x-2 > 0 && pt(2)+x+2 < size(k,1) && pt(2)-x-2 > 0
        handles.data.square_size = handles.data.square_size+2;
   
            % read in the array of the highlight region
        e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
        e=imresize(e,2);
   
        imshow(e,'parent',handles.highlightpic);
        % plot the square with the new square_size
        set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
        set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);

        guidata(hObject,handles);
    end
end
% --- Executes on button press in minus.
function minus_Callback(hObject, eventdata, handles)
% hObject    handle to minus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% similar with +
if handles.data.pt ~=0
    pt = handles.data.pt;
    handles.data.square_size = handles.data.square_size-2;
    k=handles.data.k;
   
    e = k(pt(2)-handles.data.square_size:pt(2)+handles.data.square_size,pt(1)-handles.data.square_size:pt(1)+handles.data.square_size,:);
    e=imresize(e,2);
   
    imshow(e,'parent',handles.highlightpic);
    set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
    set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);
    guidata(hObject,handles);

end

function info_Callback(hObject, eventdata, handles)
% hObject    handle to info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of info as text
%        str2double(get(hObject,'String')) returns contents of info as a double


% --- Executes during object creation, after setting all properties.
function info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get the place user click
   r=get(handles.pic,'currentpoint'); 
   pt = round(r(1,1:2));
   % if clicking at the black region or outside the picture , reset all the
   % field in handles.data
   if pt(1) > handles.data.width(2) || pt(1) < handles.data.width(1) || pt(2) > handles.data.height(2) || pt(2) < handles.data.height(1)   
       if handles.data.v ~= 0
            delete(handles.data.v);
            cla(handles.highlightpic,'reset');
            handles.data.v = 0;
            handles.data.square_size = 10;
            handles.data.pt = 0;
            guidata(hObject,handles);
       end
       
   else
    % if user click inside the picture, than highlight the place user click
        handles.data.pt = pt;
        handles.data.square_size = 10; % reset the size to 10 again
   
        if handles.data.v == 0 % if no square, create a square
            handles.pic;
            handles.data.v = plot([pt(1)-10 pt(1)+10 pt(1)+10 pt(1)-10 pt(1)-10],[pt(2)-10 pt(2)-10 pt(2)+10 pt(2)+10 pt(2)-10]);  
       
        else     
                    % if there is a highlight aquare, than move the initial
                    % square to the place user click
            set(handles.data.v,'xdata',[pt(1)-handles.data.square_size  pt(1)+handles.data.square_size  pt(1)+handles.data.square_size pt(1)-handles.data.square_size  pt(1)-handles.data.square_size]);
            set(handles.data.v,'ydata',[pt(2)-handles.data.square_size  pt(2)-handles.data.square_size  pt(2)+handles.data.square_size pt(2)+handles.data.square_size  pt(2)-handles.data.square_size]);
       
        end
   
        k=handles.data.k;
    %read the array of the highlight and show it
        e = k(pt(2)-10:pt(2)+10,pt(1)-10:pt(1)+10,:);
        e=imresize(e,2);
   
        h=imshow(e,'parent',handles.highlightpic);  
   
   
        guidata(hObject,handles);
       
   end


% --- Executes on slider movement.
function bar_Callback(hObject, eventdata, handles)
% hObject    handle to bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%get the place draging now, if the value is float than round it
a=get(handles.bar,'value');
a=round(a);
c=imread([handles.data.path '\' handles.data.list(a).name]);
% show the information of the picture on th screen , including name , rate
% size and number in the folder
[c rate]=adjust(c);
set(handles.info,'string',['Picture' ' '  int2str(a) ' of' int2str(length(handles.data.list)) ' ' handles.data.list(a).name '  ' int2str(size(c,1)) ' * '  int2str(size(c,2)) ' @'  int2str(rate*100) '%' ]);
% show the picture and reset everything
[c,width,height]=put_center(c);
imshow(c,'parent',handles.pic);
handles.data.v =0;
handles.data.square_size = 10;
handles.data.pt = 0;
handles.data.k = c;
handles.data.wihth = width;
handles.data.height = height;
handles.data.rate = rate;


guidata(hObject,handles);





% --- Executes during object creation, after setting all properties.
function bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% compressed the picture inside 300*280*3



function [k,z]=adjust(x)
    a = size(x,1)/280;
    b = size(x,2)/300; 
    
    if  a>1 && b>1
        z=max(a,b);
        z=ceil(10*z)/10;
        k=imresize(x,1/z);
        z=1/z;
    elseif a>1
        a=ceil(10*a)/10;
        k = imresize(x,1/a);
        z=1/a;
    elseif b > 1 
        b=ceil(10*b)/10;
        k = imresize(x,1/b);
        z=1/b;
    else 
        k = x;
        z=1;
    end
    




% put the compressed array array into center of 280*300 axes

function [a,x,y]=put_center(k)

%check it has 2 or 3 dimension
    if size(k,3)==3
        a = zeros([280,300,3]);
    else
        a=zeros(280,300);
    end
    
    if mod(size(k,1),2)==0 && mod(size(k,2),2)==0
       a(140+1-size(k,1)/2:140+size(k,1)/2,150+1-size(k,2)/2:150+size(k,2)/2,:)=k;

       y = [140+1-size(k,1)/2 140+size(k,1)/2];
       x = [150+1-size(k,2)/2 150+size(k,2)/2];
       
       
    elseif  mod(size(k,1),2)==0 && mod(size(k,2),2)==1
       a(140+1-size(k,1)/2:140+size(k,1)/2,150-(size(k,2)-1)/2:150+(size(k,2)-1)/2,:)=k;

       y = [140+1-size(k,1)/2 140+size(k,1)/2];
       x = [150-(size(k,2)-1)/2 150+(size(k,2)-1)/2];
        
    elseif  mod(size(k,1),2)==1 && mod(size(k,2),2)==0
       a(140-(size(k,1)-1)/2:140+(size(k,1)-1)/2,150+1-size(k,2)/2:150+size(k,2)/2,:) =k;

       y = [140-(size(k,1)-1)/2 140+(size(k,1)-1)/2];
       x = [150+1-size(k,2)/2 150+size(k,2)/2];
        
    else
        
        a(140-(size(k,1)-1)/2:140+(size(k,1)-1)/2,150-(size(k,2)-1)/2:150+(size(k,2)-1)/2,:)=k;

        y = [140-(size(k,1)-1)/2 140+(size(k,1)-1)/2];
        x = [150-(size(k,2)-1)/2 150+(size(k,2)-1)/2];
        
    end

    a=uint8(a);


% --- Executes during object creation, after setting all properties.
function pic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate pic


% --- Executes during object creation, after setting all properties.
function highlightpic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highlightpic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate highlightpic
