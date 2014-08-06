function [x_reduced, y_reduced] = reduce_to_width(x, y, axis_width_in_pixels, x_limits)
%
%   [x_reduced, y_reduced] = sl.plot.big_data.reduce_to_width(x, y, axis_width_in_pixels, x_limits)
%
%   For a given data set, this function returns the maximum and minimum
%   points within non-overlapping subsets of the data, bounded by the
%   specified limits.
%
%   This helps us to increase the rate at which we can plot data.
%
%   Inputs:
%   -------
%   x : {array, sci.time_series.time}
%       [samples x channels]
%   y : array
%       [samples x channels]
%   axis_width_in_pixels :
%       This specifies the number of min/max pairs to generate.
%   x_limits :
%       2 element vector [min,max], can be [-Inf Inf] to indicate everything
%       This limit is applied to the 'x' input to exclude any points that
%       are outside the limits.
%
%   Outputs
%   -------
%   x_reduced :
%   y_reduced :
%
%
%   Example
%   -------
%   [xr, yr] = sl.plot.big_data.reduce_to_width(x, y, 500, [5 10]);
%
%   plot(xr, yr); % This contains many fewer points than plot(x, y)
%                 %but looks the same.
%
%   Original Function By:
%   Tucker McClure (Mathworks)

n_points = 2*axis_width_in_pixels;

% If the data is already small, there's no need to reduce.
%---------------------------------------------------
if size(y, 1) <= n_points
    y_reduced = y;
    if isobject(x)
        x_reduced = x.getTimeArray();
    else
        x_reduced = x;
    end
    
    return;
end

% Reduce the data to the new axis size.
%---------------------------------------------------
n_channels_y = size(y,2);
n_channels_x = size(x,2);

x_reduced = nan(n_points, n_channels_y);
y_reduced = nan(n_points, n_channels_y);

%TODO: Rename
n_edges  = axis_width_in_pixels + 1;
% Create a place to store the indices we'll need.
%NOTE: We'll do linear indexing so we size 2 x n instead of n x 2
%so that when we linearize we get 1,2 over each span rather than
%1 over the span then 2 over the span
indices  = zeros(2,axis_width_in_pixels);

minMax_fh = @sl.array.minMaxOfDataSubset;

%TODO: Add data check

for iChan = 1:n_channels_y
    
    if iChan == 1 || n_channels_x ~= 1
        bound_indices = h__getBoundIndices(x,iChan,n_edges,x_limits);
    end
    
    %indices(:,1)   = bound_indices(1);
    %indices(:,end) = bound_indices(end);
        
    %chan_vector = [iChan iChan];
    
    %TODO: This can go really wrong if the input is a single ...
    [~,~,indices_of_max,indices_of_min] = minMax_fh(y,bound_indices(1:end-1),...
        bound_indices(2:end),iChan,iChan,1);
    
    %%%%TODO: Test vs merge and sort
    
    indices_both = [indices_of_max indices_of_min];
    indices = sort(indices_both,2)';
% % % % % % %     
% % % % % % % % % % %     mask = [false; indices_of_max > indices_of_min; false];
% % % % % % % % % % %     
% % % % % % % % % % %     indices(1,[false; ~mask]) = indices_of_max(~mask);
% % % % % % % % % % %     indices(1,[false; mask])  = indices_of_min(mask);
% % % % % % % % % % %     indices(2,
    
    
% % % %     %For each pixel get the minimum and maximum
% % % %     %---------------------------------------------
% % % %     for iRegion = 1:axis_width_in_pixels
% % % %         left  = bound_indices(iRegion);
% % % %         right = bound_indices(iRegion+1);
% % % % 
% % % %         yt = y(left:right, iChan);
% % % %         [~, index_of_max]     = max(yt);
% % % %         [~, index_of_min]     = min(yt);
% % % %         
% % % %         % Record those indices.
% % % %         %Shift back to absolute indices due to subindexing into yt
% % % %         if index_of_max > index_of_min
% % % %             indices(1,iRegion) = index_of_min + left - 1;
% % % %             indices(2,iRegion) = index_of_max + left - 1;
% % % %         else
% % % %             indices(2,iRegion) = index_of_min + left - 1;
% % % %             indices(1,iRegion) = index_of_max + left - 1;
% % % %         end
% % % %     end
    
    % Sample the original x and y at the indices we found.
    if isobject(x)
        x_reduced(:, iChan) = x.getTimesFromIndices(indices(:));
    else
        if iChan == 1 || n_channels_x ~= 1
           xt = x(:, iChan);
        end
        x_reduced(:, iChan) = xt(indices(:));
    end
    y_reduced(:, iChan) = y(indices(:), iChan);
    
end

end

function bound_indices = h__getBoundIndices(x,cur_column_I,n_points,x_limits)
%
%   Inputs:
%   -------
%   x : sci.time_series.time
%   n_points : 
%       # of boundaries to have
%   
%
%   Outputs:
%   --------
%   bound_indices :
%       length(bound_indices) => n_points , Indices are absolute relative
%       to the original data array


% Find the starting and stopping indices for the current limits.

    if isobject(x)
        
        if x_limits(1) < x.start_time
           x_limits(1) = x.start_time;
        end
        
        if x_limits(2) > x.end_time
           x_limits(2) = x.end_time; 
        end
        
        index_times   = linspace(x_limits(1),x_limits(2),n_points);
        
        bound_indices = x.getNearestIndices(index_times);
        
        %With rounding we might not bound the data. Thus we get the times
        %of the first and last indices and adjust the index values
        %accordingly if necessary
        times = x.getTimesFromIndices([bound_indices(1) bound_indices(end)]);
        
        if times(1) > x_limits(1)
            bound_indices(1)  = bound_indices(1)-1;
        end
        
        if times(2) < x_limits(2)
           bound_indices(end) = bound_indices(end)-1; 
        end
    else
        
        if x_limits(1) < x(1)
           x_limits(1) = x(1);
        end
        
        if x_limits(2) > x(end)
           x_limits(2) = x(end); 
        end
        
        xt = x(:, cur_column_I);
    
        % Map the lower and upper limits to indices.
        nx = size(x, 1);
        lower_limit      = h__binary_search(xt, x_limits(1), 1,           nx);
        [~, upper_limit] = h__binary_search(xt, x_limits(2), lower_limit, nx);

        % Make the windows mapping to each pixel.
        x_time_boundaries = linspace(x(lower_limit, cur_column_I), x(upper_limit, cur_column_I), n_points);

        bound_indices = zeros(1,n_points);
        
        bound_indices(1)   = lower_limit;
        bound_indices(end) = upper_limit;
        
        right = lower_limit;
        for iDivision = 2:n_points-1;
            % Find the window bounds.
            left       = right;
            [~, right] = h__binary_search(xt, x_time_boundaries(iDivision), left, upper_limit);
            bound_indices(iDivision) = right;
        end
    end
end

% Binary search to find boundaries of the ordered x data.
function [L, U] = h__binary_search(x, v, L, U)
%
%   Inputs:
%   --------------------
%   x : x data
%   v : 
%       value to find border for
%
%   Outputs:
%   --------
%   L : 
%       Lower index that encompasses the value 'v'
%   U : 
%       Upper index that encompasses the value 'v'
%
%
while L < U - 1                 % While there's space between them...
    C = floor((L+U)/2);         % Find the midpoint
    if x(C) < v                 % Move the lower or upper bound in.
        L = C;
    else
        U = C;
    end
end
end