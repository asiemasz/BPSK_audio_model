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
            figure; plot(input); figure; plot((corr));
            max_ = max(corr);           
            [pks, locs] = findpeaks(corr, 'MinPeakHeight',0.6 * max_,'MinPeakDistance', obj.samplesPerBit * (8 + length(obj.barkerCode)) - 20);
            locs = locs + length(obj.barkerCode) * obj.samplesPerBit;
            idx = locs;
            obj.processedBuffers = obj.processedBuffers + 1;
            length(idx)

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
