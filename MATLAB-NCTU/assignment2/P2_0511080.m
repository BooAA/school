% function P2_0511080 takes 1 argument, which is a string include numbers
% and operators
% EX: P2_0511080('1/5 + 2/5 + 4 - 3/2 - 5 + 1/4') will output the result of
% the sentence , which is -7/5 
%another example , we can input '3/5 + 8/9 - 10/31 + 1/6' as P2_0511080('3/5 + 8/9 - 10/31 + 1/6')
% and then we will get the output 3719/2790

% note : the output result is also a string






function [result] = P2_0511080(string)
    
    % delete the space string , remain only operator and number
    string(string == ' ') = [];
    
    % put each word and operator into a cell array: splitstr    
    count = 1;
    splitstr{1}=string(1);
    for ii = 2:length(string)
        
        if  string(ii) ~= '+' & string(ii) ~= '-'
             splitstr{count}=[splitstr{count} string(ii)];
             
        else 
           splitstr{count+1} = string(ii);
           count = count + 2; % count+1 store the operator , so count+2 is the place to store next fraction 
           splitstr{count} = []; % reserve the next place to store fraction as empty array
        end
        
    end
    
    for ii = 1:length(splitstr)
        
       fraction{ii}= parse(splitstr{ii}); % using parse function to handle each word , make the string-type number to a real interger number
                                          % ex '3/5'-> 3/5, '4'-> 4/1
                                          % operstor will no change i.e, 
                                          % '+'--> '+'(no different)
    end
    
    tmp = fraction{1};
    
    for ii =2:length(splitstr)-1
        if ischar(fraction{ii}(1))
            
            if fraction{ii}(1) == '+'
                tmp=add(tmp,fraction{ii+1});        % using add and substract function to do computation , the left operand 'tmp ' is the number that has been handled,                                      
            else                                    % the right operand is the next number to be process
                tmp=substract(tmp , fraction{ii+1});   % ex : '1/5 + 2/5 + 4 - 3/2 - 5 + 1/4' 
            end                                        % initial tmp = 1/5 , and the right operand is 2/5 , and we get 1/5+2/5=3/5--> stored to tmp
                                                     % now tmp = 3/5, and
                                                     % next operand is 4
        end                                          % so we do 3/5 + 4 = 23/5 , and we stored 23/5 into tmp , and do next computatin  until the end
                              
    end
    
    
    tmp = simplify(tmp);   %using simplify function to simplify the fraction 
   
    
    if tmp(1)*tmp(2)<0
      result = ['-' num2str(abs(tmp(1))) '/' num2str(abs(tmp(2)))]; % if the result is negative , we make the '-' at the beginning , that is '-7/5' rather than '7/-5'
        
    else                                                            % also , we transfer number  back to string in this step  by using num2str function 
       result = [ num2str(abs(tmp(1)))  '/'  num2str(abs(tmp(2)))]; 
    end
   
end

% parse function can transger each str to number , if the data is operator
% than we make no change, if it's an  interger like 4, we transfer it to 4/1
function [xx]=parse(x)

    if x(1)>=48   % >48 means that it is a number 
        
        if find(x==47) % find if it's a fraction or interger(so we check if there is a '/ ' in this world) 
            a=find(x==47);
            xx = [str2num(x(1:a-1)) str2num(x(a+1:end))]; % the number before '/ ' is numerator, after '/' is denominator
            %       numerator          denominator
        else 
           xx =[str2num(x)       1   ]  ;
            %   numetator    denominator
        end
        
    else  %(first element < 48--> '+' or '-' )
       xx=x; % maintain the same format
    end

end


% add two numbers
function [z] = add (x,y)
    z(1) = x(1)*y(2)+y(1)*x(2);
    z(2) = x(2)*y(2);

end


% substract two numbers
function [z] = substract(x,y)
    z(1) = x(1)*y(2)-y(1)*x(2);
    z(2) = x(2)*y(2);

end

% find the gcd by  Euclidean Algorithm 
function [z] = my_gcd(x,y)
    x=abs(x);
    y=abs(y);
    
    if x<y
        tmp = x;
        x=y;
        y=tmp;
    end
        
    while  mod(x,y) ~= 0
        tmp = mod(x,y);
        x=y;
        y=tmp;
        
    end
    z=y;

end

% using my_gcd to simplify the fraction 
function [z] = simplify(x)
    gcd=my_gcd(x(1),x(2));   
    z(1)=x(1)/gcd;
    z(2)=x(2)/gcd;

end