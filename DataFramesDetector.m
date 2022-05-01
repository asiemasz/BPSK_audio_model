classdef DataFramesDetector < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        buffer_length = 2048;
        preamble = [1 1 1 -1 1];
        data_frames_length = 8;
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

        function data_out = stepImpl(obj,symbols)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            frameLength = obj.data_frames_length + length(obj.preamble);
            plusMax = zeros(ceil(obj.buffer_length / frameLength) * 2);
            minusMax = zeros(ceil(obj.buffer_length / frameLength) * 2);
            plusCount = 0;
            minusCount = 0;
            
            correlation = xcorr(symbols, obj.preamble);
            correlation = correlation(obj.buffer_length:end);
            for i=1:length(correlation)
                if correlation(i) == length(obj.preamble)
                    plusCount = plusCount + 1;
                    plusMax(plusCount) = i;
                elseif correlation(i) == -length(obj.preamble)
                    minusCount = minusCount + 1;
                    minusMax(minusCount) = i;
                end
            end
            %figure; plot(symbols, '-o');

            if minusCount > plusCount
                symbols = -symbols;
                correlation = -correlation;
                count = minusCount;
                maximas = minusMax(1:count);
            else
                count = plusCount;
                maximas = plusMax(1:count);
            end
            start = zeros(obj.buffer_length, frameLength);
            k = 1;
            if count > 1
                prevStart = maximas(1);
                for i=2:1:length(maximas)
                    nextStart = maximas(i);
                    distance = nextStart - prevStart;
                    if distance == frameLength
                        start(k) = prevStart + length(obj.preamble);
                        k = k + 1;
                        prevStart = nextStart;
                    elseif abs(distance - frameLength) <= 2
                        start(k) = nextStart - frameLength + length(obj.preamble);
                        k = k + 1;
                        prevStart = nextStart;
                    elseif distance > (frameLength * 1.5) && (mod(distance, frameLength) <= 1 || mod(distance, frameLength) >= 12)
                        prevStart = nextStart;
                        num = floor(distance/frameLength);
                        while(num > 0)
                            nextStart = nextStart - frameLength;
                            start(k + num - 1) = nextStart + length(obj.preamble);
                            num = num - 1;
                        end
                        k = k + floor(distance / frameLength);
                    elseif i < count
                        distance_ = maximas(i + 1) - nextStart;
                        if (mod(distance_, frameLength) <= 1 || mod(distance_, frameLength) >= 12)
                            prevStart = nextStart;
                        end
                    end
                end 
                nextStart = maximas(count);
                if (nextStart - (start(k-1) - length(obj.preamble)) >= frameLength - 1) && (nextStart - (start(k-1) - length(obj.preamble)) <= frameLength + 1)
                    start(k) = nextStart + length(obj.preamble);
                else 
                    k = k-1;
                end
                %figure; plot(correlation); hold on; plot(start(1:k), 5.*ones(k, 1), 'o');
            data_out = 0;
                for i = 1:k
                    if (start(i) + obj.data_frames_length - 1 < obj.buffer_length)
                    data_out(i, 1) = bit2int((symbols(start(i):start(i) + obj.data_frames_length - 1) + 1) / 2, obj.data_frames_length);
                    end
                end

               % figure; plot(data_out, '-o');
            else
                data_out = 0;
            end
        end 

        function resetImpl(obj)
        end

        function [out,out2] = getOutputSizeImpl(obj)
            % Return size for each output port
            out = [ceil(obj.buffer_length / (obj.data_frames_length + length(obj.preamble))) 1];
            out2 = [ceil(obj.buffer_length / (obj.data_frames_length + length(obj.preamble))) 1];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function [out,out2] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = "double";
            out2 = "double";

            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        function [out,out2] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = false;
            out2 = false;

            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function [out,out2] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = false;
            out2 = false;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end

        function [sz,dt,cp] = getDiscreteStateSpecificationImpl(obj,name)
            % Return size, data type, and complexity of discrete-state
            % specified in name
            if(name == "last_idx" || name == "last_data_remaining_length")
            sz = [1 1];
            dt = "double";
            cp = false;
            else
                sz = [obj.data_frames_length 1];
                dt = "double";
                cp = false;
            end
        end
    end
end
