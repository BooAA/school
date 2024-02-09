% function P3_0511080 takes one argument, which is a path of a folder(as a
% string), and we will read all the jpg image file in the folder, and allow
% users to view the picture with different button with different function,
% EX :  we can use P3_0511080('D:\®à­±\testfile') , and we will read all the
% jpg images in the file 'testfile', we will show the first picture in the
% directory, and than users can ">" and "<" to view the next or previous
% picture, also you can use the mouse click to highlight a certain region
% you want, after you use a mouse click, you can use "+" and "-" to zoom in
% or out of the highlight region, also you can use the arrow key to move
% the hightlight square(we will use a square to show the current highlight region)
% and if you click out of the figure , you can canceal the highlight region
% ,also the highlight square will disappear. If you want to leave the
% program, you can press the "q" button ,after that , all the figure will
% close, the focus will back to the matlab command window



function [] = P3_0511080(dirpath)
   
    list=dir([dirpath '\*.jpg' ]); % use dir function to get all the jpg file in the directory, and list is a struct array containning all the information of the image
    fig = figure(1); % figure(1) is the one we will show the origin picture
    set(fig,'Position',[600 800 800 600]); % the size of the figure is 800*600 , and we will compress the image into a 640 * 480 * 3 array
    hold on;
    k=imread([dirpath '\' list(1).name]);
    [k,rate] = adjust(k); %the adjust function is a self-define function, we will explain its usage at the function definition, you can see line 224
    [k, width , height,]=put_center(k); % the put_center function will make the image at the cinter of the 640*480*3 array, you can see more explanation at line 250
    
    currentpic = 1; % a counter to check which picture is showing now 
    v = 0; % v is the handles of the highlight square, at first its 0, we will assign it as the handles of highlight square after
    
    imshow(k); %show the first picture in the directory and the information of the picture at the title
    title(['Picture ' int2str(currentpic) ' of ' int2str(length(list)) ' ' list(currentpic).name ' ' int2str(size(k,1)) ' * ' int2str(size(k,2))  ' @'   int2str(round(rate*100)) '%']);
    square_size = 10; % the initial highlight square size, at first it's 10*10 square
    currentpoint = 0; % the positon of the mouse click, at first it's 0, 

    while 1
        tt = waitforbuttonpress; 
        
        % below is the part of using typeing a button
        
        
        if tt == 1
            c = get(gcf,'CurrentCharacter'); %get the input character 
            if c == '>' 
                currentpic = currentpic + 1;  % change to the next picture
                if currentpic == length(list)+1
                    currentpic = 1;
                end
                k=imread([dirpath '\' list(currentpic).name]); %typing ">" we will show the next picture and canceal the highlight square if necessary
                [k,rate] = adjust(k);
                [k,width,height]=put_center(k);
                
                imshow(k);
                title(['Picture '   int2str(currentpic)  ' of '  int2str(length(list)) ' ' list(currentpic).name  ' ' int2str(size(k,1)) '*'  int2str(size(k,2)) ' @' int2str(round(rate*100)) '%']);
                % if it has a highlight square, we remove it
                if v ~= 0 % to check whether it has a highlight square
                   delete(v); 
                   close(figure(2));
                   v = 0;
                   currentpoint = 0; % set the point of the highlight back to 0
                end
                
                % do the similar thing as ">"
            elseif c == '<'
                currentpic = currentpic - 1;
                if currentpic == 0
                   currentpic = length(list); 
                    
                end
                k = imread([dirpath '\' list(currentpic).name]); %typing "<" we will show the previous picture and canceal the highlight square if necessary
                [k,rate] = adjust(k);
                [k,width,height]=put_center(k);
               
                imshow(k);
                title(['Picture ' int2str(currentpic) ' of ' int2str(length(list)) ' ' list(currentpic).name ' ' int2str(size(k,1)) ' * ' int2str(size(k,2))  ' @' int2str(round(rate*100)) '%']);
                if v ~= 0
                   delete(v); 
                   close(figure(2));
                   v = 0;
                   currentpoint = 0;
                end
                
            elseif c == '+' % pressing "+" , we will make the highlight square_size+2, and replot the highlight square, if the highlight will exceed the figure, we will do nothing
                
                    %check if it will exceed the figure first 
                    if currentpoint~=0
                        if currentpoint(2) + square_size+2 <= size(k,1) && currentpoint(2)-square_size-2 > 0 && currentpoint(1) + square_size+2 <= size(k,2) && currentpoint(1) - square_size-2 > 0 
                            
                            if square_size+2 <= 20
                                square_size = square_size+2;
                        % replot the square
                                set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                                set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                                e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                                e=imresize(e,5);
                                figure(2);
                                imshow(e); % show the hilight region on the figure(2)
                                figure(1);
                    
                            end
                        end
                    end
                
            elseif c == '-'
                % do the similar things as perssing "+", however we decrease
                % the square_size by 2, the other thing is same
                if currentpoint ~= 0
                    if square_size-2 > 0
                        square_size = square_size-2;
                        set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                        set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                        e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                        e=imresize(e,5);
                        figure(2);
                        imshow(e);
                        figure(1);
                    end
                    
                end
                %{
                below is the ascii number of different arrow key
                29 = right
                28 = left
                31 = down
                30 = up
                %}
            elseif  c == 29
                    if currentpoint ~= 0 % check whether there is a  highlight square on the figure
                       if currentpoint(1,1)+5 <= width(2) % check whether the center of the square will exceed the image
                        if currentpoint(1,1)+5+square_size < size(k,2) % check whether the square will exceed the whole figure
                            currentpoint(1,1) =currentpoint(1,1) + 5; % move the center right by 5
                            %replot the highlight square
                            set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                            set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                            e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                            e=imresize(e,5);
                            figure(2); % show the highlight square on figure(2) 
                            imshow(e);
                            figure(1); % move focus back to figure(1)
                        end
                       end
                    end
            % similar as pressing right arrow
            elseif  c == 28
                    if currentpoint ~= 0
                        if currentpoint(1,1)-5 > width(1)
                            if currentpoint(1,1)-5-square_size >0
                                currentpoint(1,1) =currentpoint(1,1) - 5; 
                                set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                                set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                                e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                                e=imresize(e,5);
                                figure(2);
                                imshow(e);
                                figure(1);
                            
                            end
                        end
                    end
              %similar as above
            elseif  c == 31
                    if currentpoint ~=0     
                        if currentpoint(1,2)+5 <= height(2)
                            if currentpoint(1,2)+5 + square_size < size(k,1)
                                currentpoint(1,2) =currentpoint(1,2) + 5; 
                                set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                                set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                                e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                                e=imresize(e,5);
                                figure(2);
                                imshow(e);
                                figure(1);
                            end
                        end
                    end
            %similar as above
            elseif  c == 30
                    if currentpoint ~= 0
                        if currentpoint(1,2) -5-square_size > 0
                            if currentpoint(1,2)-5 >height(1)
                                currentpoint(1,2) =currentpoint(1,2) - 5; 
                                set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                                set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                                e = k(currentpoint(2)-square_size:currentpoint(2)+square_size,currentpoint(1)-square_size:currentpoint(1)+square_size,:);
                                e=imresize(e,5);
                                figure(2);
                                imshow(e);
                                figure(1);
                            end
                        end
                    end
            elseif c == 'q'
                delete(figure(1));
                delete(figure(2)); 
                
                
                % pressing q so that we will exit the whole figure 
                break;
               
            end
            
          % below is the thing we do when using a mouse click  
            
            
        else 
            r=get(gca,'CurrentPoint');
            
            
            % if the position user click is outside the image, we will
            % canceal the highlight square if necessary
            if r(1,1) > width(2) || r(1,1) < width(1) || r(1,2) > height(2) || r(1,2) < height(1)
                if v ~=0
                    delete(v);
                    close(figure(2));
                    v = 0;
                    square_size = 10;
                    currentpoint = 0;
                end
                
                
             % using clicking inside the image   
            else 
             
                    currentpoint = round(r(1,1:2));
                    figure(fig);
                    hold on;
                    square_size = 10;
                    if v ==0; % if there is no highlight square , we plot it on the position that user click
                        v = plot([currentpoint(1)-10 currentpoint(1)+10 currentpoint(1)+10 currentpoint(1)-10 currentpoint(1)-10],[currentpoint(2)-10 currentpoint(2)-10 currentpoint(2)+10 currentpoint(2)+10 currentpoint(2)-10]);
                    else  % if the highlight square is exiting , we replot it at the position users click now
                        set(v,'Xdata',[currentpoint(1)-square_size currentpoint(1)+square_size currentpoint(1)+square_size currentpoint(1)-square_size currentpoint(1)-square_size]);
                        set(v,'Ydata',[currentpoint(2)-square_size currentpoint(2)-square_size currentpoint(2)+square_size currentpoint(2)+square_size currentpoint(2)-square_size]);
                % note: v is the handle of the highlight square
                    end
            
                % below is the process we extract the place the user want to highlight(the default size is 10*10 , center is the place user click) 
                    e = k(currentpoint(2)-10:currentpoint(2)+10,currentpoint(1)-10:currentpoint(1)+10,:);
                      
                    c=figure(2);
                    set(c,'Position',[100 100 240 160]);%set the position of the place of figure(2) on the screen
                    e = imresize(e,5);
                    imshow(e);
                    figure(fig);% move focus back to figure(1)
                              
            end
        end
        
        
    end
    

end




% the adust function takes a argument, which is a array(M*N*3),and we will
% check the size of the array and compress it if any of its size is larger
% the 640* 480, the detail solution we will use an example to demo
% if we input a array with [1000* 800 *3], and we will check 1000/640
% =1.5625 and 800/480=1.66 , we will pick the larger rate of this 2 size,so
% we use imresize(x,1/1.66) as the output array, 
% if both of the size is smaller [640 * 480] , we will do nothing,EX it¡@will
% do nothing if you input [500 300], we will return the same array back.



function [k,z]=adjust(x)            
    a = size(x,1)/640;
    b = size(x,2)/480; 
    
    if  a>1 && b>1
        z=max(a,b);
        z = ceil(10*z)/10;
        k=imresize(x,1/z);
        z=1/z;
    elseif a>1
        a = ceil(10*a)/10;
        k = imresize(x,1/a);
        z=1/a;
    elseif b > 1 
        b = ceil(10*b)/10;
        k = imresize(x,1/b);
        z=1/b;
    else 
        k = x;
        z=1;
    end
    
end



%function put_center will take 1 arguments(an M*N*3 array), and we will put the input array
%into a [640* 480 *3] array , the image will be placed at the center of the
%figure , the outside of the showing image will be black if it's smaller
%than 640*480
% like this:
%{
        -------------
        |   black   |
        |   |---|   |
        |   |   |   |
        |   |---|   |
        -------------


%}


function [a,x,y]=put_center(k)
    a = zeros([640,480,3]);
    
    
    % we will check whether the width and height is odd or ever number, we will take dirrerent solution for different case 
    if mod(size(k,1),2)==0 && mod(size(k,2),2)==0 
       a(320+1-size(k,1)/2:320+size(k,1)/2,240+1-size(k,2)/2:240+size(k,2)/2,1)=k(:,:,1);
       a(320+1-size(k,1)/2:320+size(k,1)/2,240+1-size(k,2)/2:240+size(k,2)/2,2)=k(:,:,2);
       a(320+1-size(k,1)/2:320+size(k,1)/2,240+1-size(k,2)/2:240+size(k,2)/2,3)=k(:,:,3);
       y = [320+1-size(k,1)/2 320+size(k,1)/2];
       x = [240+1-size(k,2)/2 240+size(k,2)/2];
       
       
    elseif  mod(size(k,1),2)==0 && mod(size(k,2),2)==1
       a(320+1-size(k,1)/2:320+size(k,1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,1)=k(:,:,1);
       a(320+1-size(k,1)/2:320+size(k,1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,2)=k(:,:,2);
       a(320+1-size(k,1)/2:320+size(k,1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,3)=k(:,:,3); 
       y = [320+1-size(k,1)/2 320+size(k,1)/2];
       x = [240-(size(k,2)-1)/2 240+(size(k,2)-1)/2];
        
    elseif  mod(size(k,1),2)==1 && mod(size(k,2),2)==0
       a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240+1-size(k,2)/2:240+size(k,2)/2,1) =k(:,:,1);
       a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240+1-size(k,2)/2:240+size(k,2)/2,2) =k(:,:,2);
       a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240+1-size(k,2)/2:240+size(k,2)/2,3) =k(:,:,3);
       y = [320-(size(k,1)-1)/2 320+(size(k,1)-1)/2];
       x = [240+1-size(k,2)/2 240+size(k,2)/2];
        
    else
        
        a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,1)=k(:,:,1);
        a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,2)=k(:,:,2);
        a(320-(size(k,1)-1)/2:320+(size(k,1)-1)/2,240-(size(k,2)-1)/2:240+(size(k,2)-1)/2,3)=k(:,:,3);
        y = [320-(size(k,1)-1)/2 320+(size(k,1)-1)/2];
        x = [240-(size(k,2)-1)/2 240+(size(k,2)-1)/2];
        
        
    end

    a=uint8(a); % make the array back to uint8 , which is the initial data type read by imread function
end