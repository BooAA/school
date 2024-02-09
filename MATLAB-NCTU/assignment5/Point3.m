% this Point3 will take 0 or 3 arguments, if you use Point3() or Point3, you will get the default value with x = y = z = 0;
% if you give 3 arguments(3 scalars or 3 input arrays with same size), you
% can assign your own x, y ,z value
% and there are some function being overloaded to let you operate the
% Point3 object, there are +, - , == ,sum, mean, disp  we provide the similar
% usage as you use in original matlab function

classdef Point3
    properties
       % set 3 properties with x, y, z(default value is 0) 
       x = 0;
       y = 0;
       z = 0;
    end
    
    methods
        % constructor 
        function obj = Point3(x,y,z)
            % no input, use dafault value;
           if nargin == 0
              obj.x = 0; 
              obj.y = 0;
              obj.z = 0;
        % 3 inputs, assign value to its corresponding properties
           elseif nargin == 3
               obj(1:numel(x)) = Point3;
               for ii = 1:numel(x)
                   obj(ii).x = x(ii);
                   obj(ii).y = y(ii);
                   obj(ii).z = z(ii);
               end
               obj = reshape(obj,size(x));   
               % other cases will cause input error message
           else
               error('Input Error');
           end   
        end
        % show the properties like matlab
        function output = disp(input)
            if ndims(input) <= 3
               if ndims(input) == 1
                  fprintf('(%d , %d , %d)', input.x , input.y , input.z); 
               elseif ndims(input) == 2
                   for ii = 1:size(input,1)
                      for jj = 1:size(input,2)
                         fprintf('(%d , %d , %d) ',input(ii,jj).x , input(ii,jj).y , input(ii,jj).z); 
                      end
                      fprintf('\n');
                   end
               else
                   for kk = 1:size(input,3)
                      fprintf(':,:,%d \n',kk);
                      for ii = 1:size(input,1)
                         for jj = 1:size(input,2)
                             fprintf('(%d , %d , %d) ',input(ii,jj,kk).x , input(ii,jj,kk).y , input(ii,jj,kk).z);
                         end
                         fprintf('\n');
                      end
                   end                
               end
            else
                % cut the dimensions over 3, and show the array(2 dimensions ) in linear order 
                inputsize = size(input);
                inputsize_cut = inputsize(3:end);               
                indx = cell(length(inputsize_cut),1);
                count1 = size(input,1) * size(input,2); % the number of elements to show at one times
                count2 = 0; % will increase count1 after one display
                tmp(1:size(input,1),1:size(input,2)) = Point3;
                for ii = 1:prod(inputsize_cut)
                    [indx{:}] = ind2sub(inputsize_cut,ii);
                    fprintf(':,:');
                    for aa = 1:numel(inputsize_cut)
                        fprintf(',%d',indx{aa}(1));
                    end
                    fprintf('\n');
                    for jj = 1:count1
                        tmp(jj) = input(jj+count2);
                    end
                    count2 = count1 + count2;
                    for bb = 1:size(tmp,1)
                        for cc = 1:size(tmp,2)
                            fprintf('(%d , %d , %d) ',tmp(bb,cc).x,tmp(bb,cc).y,tmp(bb,cc).z);
                        end
                        fprintf('\n');
                    end  
                end
            end        
        end
        
        % plus 2 Point3 objects(object array)
        function output = plus(arg1,arg2)
            if ~isscalar(arg1) && isscalar(arg2)
                output(1:numel(arg1)) = Point3;
                for ii = 1:numel(arg1)
                     output(ii).x = arg1(ii).x + arg2.x;
                     output(ii).y = arg1(ii).y + arg2.y;
                     output(ii).z = arg1(ii).z + arg2.z;
                end
                output = reshape(output,size(arg1)); % reshape the object array back to the initial size as input argument
            elseif isscalar(arg1) && ~isscalar(arg2)
                output(1:numel(arg2)) = Point3;
                for ii = 1:numel(arg2)
                     output(ii).x = arg1.x + arg2(ii).x;
                     output(ii).y = arg1.y + arg2(ii).y;
                     output(ii).z = arg1.z + arg2(ii).z;
                end
                output = reshape(output,size(arg2));                
            else
                if length(size(arg1)) ~= length(size(arg2))
                    error('cannot plus 2 arrays with differert dimension numbers');
                else
                    if ~all(size(arg1) == size(arg2))
                        error('cannot plus 2 arrays with differert size');
                    else
                        output(1:numel(arg1)) = Point3;
                        for ii = 1:numel(arg1)
                           output(ii).x = arg1(ii).x + arg2(ii).x;
                           output(ii).y = arg1(ii).y + arg2(ii).y;
                           output(ii).z = arg1(ii).z + arg2(ii).z;
                        end
                        output = reshape(output,size(arg1));
                    end                
                end               
            end            
        end
        % minus 2 Point3 objects (object array)
        function output = minus(arg1,arg2)
            if ~isscalar(arg1) && isscalar(arg2)
                output(1:numel(arg1)) = Point3;
                for ii = 1:numel(arg1)
                    output(ii).x = arg1(ii).x - arg2.x;
                    output(ii).y = arg1(ii).y - arg2.y;
                    output(ii).z = arg1(ii).z - arg2.z;
                end
                output = reshape(output,size(arg1)); % reshape the object array back to the initial size as input argument
            elseif isscalar(arg1) && ~isscalar(arg2)
                output(1:numel(arg2)) = Point3;
                for ii = 1:numel(arg2)
                    output(ii).x = arg1.x - arg2(ii).x;
                    output(ii).y = arg1.y - arg2(ii).y;
                    output(ii).z = arg1.z - arg2(ii).z;
                end
                output = reshape(output,size(arg2));   
            else
                if length(size(arg1)) ~= length(size(arg2))
                    error('cannot plus 2 arrays with differert dimension numbers');
                else
                    if ~all(size(arg1) == size(arg2))
                        error('cannot plus 2 arrays with differert size');
                    else
                        output(1:numel(arg1)) = Point3;
                        for ii = 1:numel(arg1)
                           output(ii).x = arg1(ii).x - arg2(ii).x;
                           output(ii).y = arg1(ii).y - arg2(ii).y;
                           output(ii).z = arg1(ii).z - arg2(ii).z;
                        end
                        output = reshape(output,size(arg1));
                    end                
                end                                
            end        
        end
        
        function output = eq(arg1,arg2)
            if ~isscalar(arg1) && isscalar(arg2)
                output(1:numel(arg1)) = false;
                for ii = 1:numel(arg1)
                    if arg1(ii).x == arg2.x && arg1(ii).y == arg2.y && arg1(ii).z == arg2.z % check if every elements in the object(object array) is correct
                        output(ii) = true;
                    end
                end
                output = reshape(output,size(arg1));
            elseif isscalar(arg1) && ~isscalar(arg2)
                output(1:numel(arg2)) = false;
                for ii = 1:numel(arg2)
                    if arg1.x == arg2(ii).x && arg1.y == arg2(ii).y && arg1.z == arg2(ii).z
                        output(ii) = true;
                    end
                end
                output = reshape(output,size(arg2));
            else
                if ndims(arg1) ~= ndims(arg2) % check whether they are in same dimension (if not , we cannot use the size function to compare each dimension)
                    error('cannot compare 2 arrays with differert dimension numbers');
                elseif all(size(arg1) == size(arg2))
                    output(1:numel(arg1)) = false;
                    for ii = 1:numel(arg1)
                        if arg1(ii).x == arg2(ii).x && arg1(ii).y == arg2(ii).y && arg1(ii).z == arg2(ii).z
                            output(ii) = true;
                        end
                    end
                    output = reshape(output,size(arg1));
                else
                    error('cannot compare 2 arrays with differert size');
                end
            end
        end
        
        function output = norm(input)
            % computing the length of each vector(or vector array)
            output(1:numel(input)) = 0;
            for ii = 1:numel(input)
               output(ii) = ( (input(ii).x)^2 + (input(ii).y)^2 +(input(ii).z)^2 )^(1/2);
            end
            output = reshape(output,size(input));
        end
        
        function  output = sum(arg1,arg2)

            % extract element of each propertiy, and we can use the matlab original sum function
            xx(1:numel(arg1)) = 0;% xx, yy zz means the array which extracting the value of properties x, y ,z
            yy(1:numel(arg1)) = 0;
            zz(1:numel(arg1)) = 0;
            for ii = 1:numel(arg1)
               xx(ii) = arg1(ii).x;
               yy(ii) = arg1(ii).y;
               zz(ii) = arg1(ii).z;
            end
            xx = reshape(xx,size(arg1));
            yy = reshape(yy,size(arg1));
            zz = reshape(zz,size(arg1));
            if nargin == 1
                tmp = find(size(arg1) ~= 1);
                dim = tmp(1);
                xx = sum(xx,dim);
                yy = sum(yy,dim);
                zz = sum(zz,dim);
                output = Point3(xx,yy,zz);  % using the constructor to build a new Point3 object 
            elseif nargin == 2
                if ndims(arg1) < arg2
                    error('cannot handle dimension over the array');  % check whether the request dimension will exceed the size of array
                end                
                xx = sum(xx,arg2);
                yy = sum(yy,arg2);
                zz = sum(zz,arg2);
                output = Point3(xx,yy,zz);
            else
                error('Too many input argument to use member function-sum ');
            end            
        end
        
        function  output = mean(arg1,arg2)
            
            % extract element of each propertiy, and we can use the matlab original mean function 
            xx(1:numel(arg1)) = 0; % xx, yy zz means the array which extracting the value of properties x, y ,z
            yy(1:numel(arg1)) = 0;
            zz(1:numel(arg1)) = 0;
            for ii = 1:numel(arg1)
               xx(ii) = arg1(ii).x;
               yy(ii) = arg1(ii).y;
               zz(ii) = arg1(ii).z;
            end
            xx = reshape(xx,size(arg1));
            yy = reshape(yy,size(arg1));
            zz = reshape(zz,size(arg1));             
            if nargin == 1
                tmp = find(size(arg1) ~= 1);
                dim = tmp(1);
                xx = mean(xx,dim);
                yy = mean(yy,dim);
                zz = mean(zz,dim);
                output = Point3(xx,yy,zz); % using the constructor to build a new Point3 object 
            elseif nargin == 2
                if  ndims(arg1) < arg2
                    error('cannot handle dimensions over input array'); % check whether the request dimension will exceed the size of array
                end
                xx = mean(xx,arg2);
                yy = mean(yy,arg2);
                zz = mean(zz,arg2);
                output = Point3(xx,yy,zz);
            else
                error('Too many input argument to use member function-mean ');
            end           
        end        
               
    end
    
end