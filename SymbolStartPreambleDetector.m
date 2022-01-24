classdef SymbolStartPreambleDetector < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        barkerCode = [1 1 1 -1 1];
        samplesPerBit = 48;
        symbolLength = 8;
        inputBufferLength = 2048;
    end

    properties(DiscreteState)
        processedBuffers;
    end

    % Pre-computed constants
    properties(Access = private)
        maxSymbolsNum;
        barkerCode_;
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
        end

        function idx = stepImpl(obj,input)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            idx = zeros(obj.maxSymbolsNum, 1);
            corr = xcorr(input, obj.barkerCode_);
            corr = corr(obj.inputBufferLength-1:end);
            absMax = max(corr);           
            %[pks, locs] = findpeaks(corr, 'MinPeakHeight',0.5 * max_,'MinPeakDistance', obj.samplesPerBit * (8 + length(obj.barkerCode)) - obj.samplesPerBit/2);
            %locs = locs + length(obj.barkerCode) * obj.samplesPerBit;
            %idx = locs;
            i = 1;
            k = 1;
            locked = false;
            while i < obj.inputBufferLength - (obj.symbolLength + length(obj.barkerCode)) * obj.samplesPerBit 
                if ~locked
                    [currMax, currIdx] = max(corr(i:i + obj.symbolLength * obj.samplesPerBit));
                    if currMax > 0.5 * absMax
                        locked = true;
                        idx(k) = i + currIdx + length(obj.barkerCode) * obj.samplesPerBit;
                        i = idx(k) + obj.symbolLength * obj.samplesPerBit;
                        k = k + 1;
                    else
                        i = i + obj.symbolLength * obj.samplesPerBit;
                    end
                else
                    [currMax, currIdx] = max(corr(i-obj.samplesPerBit:i+obj.samplesPerBit));
                    if currMax > 0.5 * absMax
                        idx(k) = i - obj.samplesPerBit + currIdx + length(obj.barkerCode) * obj.samplesPerBit;
                        i = idx(k) + obj.symbolLength * obj.samplesPerBit;
                        k = k + 1;
                    else
                        locked = false;
                        i = i + obj.samplesPerBit;
                    end
                end
            end
            obj.processedBuffers = obj.processedBuffers + 1;
        end 

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.processedBuffers = 0;
            obj.maxSymbolsNum = floor(obj.inputBufferLength / (obj.samplesPerBit * (obj.symbolLength + length(obj.barkerCode))));
            y = repmat(obj.barkerCode', 1, obj.samplesPerBit).';
            y = y(:).';
            obj.barkerCode_ = y;
        end

        function sizeout = getOutputSizeImpl(~)
            sizeout = [100, 1];
        end

        function datatype = getOutputDataTypeImpl(~)
            datatype = 'double';
        end

        function cplxout = isOutputFixedSizeImpl(~)
            cplxout = false;
        end
        
         function [sz,dt,cp] = getDiscreteStateSpecificationImpl(~,name)
            if strcmp(name,'processedBuffers')
                sz = [1 1];
                dt = 'double';
                cp = false;
            else
                error(['Error: Incorrect State Name: ', name.']);
            end
        end
    end
end
