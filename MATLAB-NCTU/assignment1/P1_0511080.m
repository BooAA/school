%function "P1_0511080" take 2 arguments, first argument is a 2-element array
%,second one is a interger deciding the number of mines
% Also it can support at most 2 outputs, first one will be the board of "number of mines"
% the second one is the position of each mine
% EX: [x,y]=P1_0511080([16,32],100) 
% x = the number-of-mine board (0~8 == number of mines , 10 == place reserved to dram mine, 9==black , to represent mine)
% y = the position of board(0 means not, 1 means yes )


function [board, mboard] = P1_0511080(arraysize, nmine )
    % arraysize(1)=height, arraysize(2)=width
    %"board"  : array recording the value of mine around any point (mine will be represent with the composition of 9 and 10 
    % 9 represent the black part of the mine,   as figure 2 below
    % 10 represent the white line outside the mine
    
    %"mboard" : array with the position of mine (position with 1 is the place of mine)
    %"mboard2": using 0 as the wall to surround mboard, I will use it to
    %count how many mines surrounded one position later

    board=zeros(arraysize);
    
    randresult = randperm(arraysize(1)*arraysize(2)); %create a random permutation of 1~16*32
    k = find(randresult<=nmine); %find 1~100 in randresult 
    
    mboard = board;
    mboard(k) = 1; %use linear index to put mine onto the table
    
    %using 0 to sorround board and assign it as mboard2
    mboard2 = zeros(arraysize(1)+2,arraysize(2)+2);
    
    % 0 represents wall, inside the wall is the number of mines for each position 
    mboard2([2:arraysize(1)+1],[2:arraysize(2)+1]) = mboard;  
    
    
    %check every direction whether there is a mine
    c1 = mboard2([1:arraysize(1)],[2:arraysize(2)+1]); %up side
    c2 = mboard2([2:arraysize(1)+1],[3:arraysize(2)+2]); % right 
    c3 = mboard2([3:arraysize(1)+2],[2:arraysize(2)+1]); % down 
    c4 = mboard2([2:arraysize(1)+1],[1:arraysize(2)]); % left 
    c5 = mboard2([1:arraysize(1)],[3:arraysize(2)+2]); % up right 
    c6 = mboard2([3:arraysize(1)+2],[3:arraysize(2)+2]); % down right
    c7 = mboard2([3:arraysize(1)+2],[1:arraysize(2)]); % down left
    c8 = mboard2([1:arraysize(1)],[1:arraysize(2)]); % up left
    
    
    % sum of the logical array = number of mine 
    board = c1+c2+c3+c4+c5+c6+c7+c8;
    
    % 10 = white , using white space to reserve space for drawing mine
    % later
    board(k) = 10;
    
    % create a bigger 36 times board :board3
    % ampligy 1 pixel to 5*5 block ,    6*6-5*5 = border
    
    % the outside part of the 6*6 block is border(using black line)
    % the inside part of the 6*6(i,e, the 5*5 inside 6*6) is number of mines
    
    
    % expand a pixel to 5*5 block 
    x = ceil((1:size(board,2)*5)/5);
    y = ceil((1:size(board,1)*5)/5);
    [xx,yy]=meshgrid(x,y);
    index=sub2ind(size(board),yy,xx);
    board2=board(index);
    % note : board2 now is the result of expanding a pixel to 5*5 block     
    
    
    % drawing mine onto the board
    %deciding the position to draw mine on the board
    [x,y]=find(board==10);
    x=5*x;
    y=5*y;
    y=y-1;
    % now x,y is the start position(the start pixel) of each block to draw mine 
    %ex  10  10  10  10  10
    %    10  10  10  10  10     <--figure 1 
    %    10  10  10  10  10
    %    10  10  10  10  10
    %    10  10  10 [10] 10     x,y is point at the place I take a bracket
    
    % label all the pixel to be drawn as mine
    b=sub2ind(size(board2),x,y); %transfer x,y to linear index
    [xx,yy]=meshgrid(1:3,1:3); 
    c=sub2ind(size(board2),xx,yy); % the corresponding linear index of 3*3 block on board2 (used to draw mine later)
    b1=repmat(b',length(c(:)),1);
    c1=repmat(c(:),1,length(b'));
    minepos=b1-c1; % all the position do draw pixel of mine
    board2(minepos)=9; % 9 represent black in my colormap, so I draw the pixel black to represent mine
    
    %ex  10  10  10  10  10
    %    10  9   9   9   10     <--figure 2 
    %    10  9   9   9   10     % 9 = black
    %    10  9   9   9   10     % 10 = white
    %    10  10  10 [10] 10  
    
            
    
    % adding the border (9=black in the colormap)
    
    board3=ones(size(board)*6);
    board3(:,1:6:size(board3,2))=9;
    board3(1:6:size(board3,1),:)=9;
    % after drawing the border, put the pixel block into  board3         
    board3(board3==1)=board2;
    
    % now the each block of the board become
    % ex 9  9  9  9  9  9  9
    %    9  5  5  5  5  5  9
    %    9  5  5  5  5  5  9    figure 3
    %    9  5  5  5  5  5  9    5= number of mines around 1
    %    9  5  5  5  5  5  9    9 = black = border
    %    9  9  9  9  9  9  9           
        
    % handling the boundery condition of the border
    board3(:,size(board3,2)+1)=9;
    board3(size(board3,1)+1,:)=9;
    
    % show the figure ,using a designed colormap 
    figure(1);  
    des_colormap = [0 1 0.0156 ; 0 1 0.7656 ; 0 1 1 ; 0 0.8125 1 ; 0 0.625 1 ; 1 1 0 ; 0.6406 1 0.345 ;1 0 1; 0.876 0.34 1;0 0 0 ; 1 1 1];    
        
    RGB=ind2rgb(uint8(board3),des_colormap);  
    imshow(RGB);
    hold on;
    
    % texting each position with its number of mine 
    for ii =0:8
        [x,y]=find(board==ii);
        x=6*x; % the corresponding position of each pixel on 6*6 board  
        y=6*y;
        text(y-3,x-2,num2str(ii));
    end
             
    hold off;
    
      
end

