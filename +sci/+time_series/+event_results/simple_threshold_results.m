classdef simple_threshold_results < handle
    %
    %   Class:
    %   sci.time_series.event_results.simple_threshold_results
    %
    %   TODO: Do we want to inherit from some event_results class????
    
    properties
       %TODO: We could do lazy evaluation if we hold onto the
       %bool_transition_info and the mask
       threshold_start_times
       threshold_start_I
       threshold_end_times
       threshold_end_I
    end
    
    %TODO: How many do we remove from time filtering ????
    
    methods
    end
    
end

