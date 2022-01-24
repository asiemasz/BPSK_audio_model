classdef BPSK_Decoder < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        samplesPerBit = 48;
        symbolLength = 8;
        inputBufferSize = 24000;
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

        function y = stepImpl(obj,input, idx)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            if(length(idx) > 0)
                y = zeros(length(idx)*8, 1);
                spb = obj.samplesPerBit;
                k = 1;
                for i = 1:length(idx)
                    if(idx(i)+spb*8 < obj.inputBufferSize && idx(i) > 0)
                        for j = 0:spb:spb*7
                            if sum(input(idx(i)+j:idx(i)+j+obj.samplesPerBit)) < 0
                                y(k) = 1;
                            else
                                y(k) = 0;
                            end
                            k = k+1;
                        end
                    end
                end
            else 
                y = 0;
            end
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end


        function sizeout = getOutputSizeImpl(~)
            sizeout = [2000, 1];
        end

        function datatype = getOutputDataTypeImpl(~)
            datatype = 'double';
        end

        function cplxout = isOutputComplexImpl(~)
            cplxout = false;
        end

        function cplxout = isOutputFixedSizeImpl(~)
            cplxout = false;
        end
    end
end
