classdef callback_info < handle
    %
    %   Class:
    %   sl.plot.big_data.line_plot_reducer.callback_info
    %
    %   I want this to be a singleton for debugging
    %
    %   I'm not sure of the details yet ...
    %
    
    properties
       doing
       history
       cur_history_I
    end
    
    methods (Access = private)
        function obj = callback_info
            obj.history = cell(1,50000);
            obj.cur_history_I = 0;
        end
        function addToHistory(obj,msg)
           I = obj.cur_history_I + 1;
           if I > length(obj.history)
               I = 1;
           end
           obj.history{I} = msg;
        end
    end
    methods (Static)
        function single_obj = getInstance
            %
            %   sl.plot.big_data.line_plot_reducer.callback_info.getInstance
            persistent local_obj
            if isempty(local_obj) || ~isvalid(local_obj)
                local_obj = sl.plot.big_data.line_plot_reducer.callback_info;
            end
            single_obj = local_obj;
        end
    end
    
end
