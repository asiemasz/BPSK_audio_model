classdef calculateBER < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties

    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
        end

        function ber = stepImpl(obj,in1, in2)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            x = find(in1==in2);
            ber = 1 - length(x)/length(in1);
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end

        function sizeout = getOutputSizeImpl(~)
            sizeout = [1, 1];
        end

        function datatype = getOutputDataTypeImpl(~)
            datatype = 'double';
        end

        function cplxout = isOutputComplexImpl(~)
            cplxout = false;
        end

        function cplxout = isOutputFixedSizeImpl(~)
            cplxout = true;
        end
    end
end
