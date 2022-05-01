classdef GardnerTimingRecovery < matlab.System
    % untitled2 Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        Kp; %Proportional gain
        Ki; %Integral gain
        samplesPerBit;
    end

    properties(DiscreteState)
        last_sample;
        last_idx;
        mu;
        m_k;    
        v; %PI output 
        v_i; %PI integral 
        W;
        strobe;
        cnt;
        zc_idx; %zero crossing
        sample_zc;
        sample;
        i;
    end

    % Pre-computed constants
    properties(Access = private)
        midpoint_offset;
        delay_line;
        delay_idx;
    end

    methods(Access = protected)
        function setupImpl(obj)
            obj.midpoint_offset = obj.samplesPerBit / 2;
            % Perform one-time calculations, such as computing constants
        end

        function [output, sample, index, error, v] = stepImpl(obj,input)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            output = sign(obj.last_sample);
            sample = 0;
            index = 0;
            error = 0;
            if obj.delay_idx == length(obj.delay_line)
                obj.delay_line = circshift(obj.delay_line, -1);
            else 
                obj.delay_idx = obj.delay_idx + 1;
            end
            obj.delay_line(obj.delay_idx) = input;
                if(obj.strobe == 1)
                    obj.sample = obj.interpolateLinear(obj.delay_line, mod(obj.m_k - 2, length(obj.delay_line)), obj.mu); 
                    obj.zc_idx = obj.m_k - obj.midpoint_offset;
                    obj.sample_zc = obj.interpolateLinear(obj.delay_line, mod(obj.zc_idx - 1, length(obj.delay_line)), obj.mu); 
                    error = obj.sample_zc * (obj.last_sample - obj.sample);
                    obj.last_sample = obj.sample;
                    output = sign(obj.sample);
                    sample = obj.last_sample;
                    index = obj.m_k;
                else
                    error = 0;
                end
                obj.v_i = obj.v_i + obj.Ki * error;
                obj.v = obj.Kp * error + obj.v_i;
                obj.W = 1 / obj.samplesPerBit + obj.v;
                v = obj.v;
                if obj.cnt < obj.W 
                    obj.strobe = 1;
                else 
                    obj.strobe = 0;
                end
                if(obj.strobe == 1)
                    obj.m_k = obj.i;
                    obj.mu = obj.cnt / obj.W;
                end
                obj.cnt = obj.cnt - obj.W;
                obj.cnt = mod(obj.cnt, 1);
                obj.i = obj.i + 1;
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.cnt = 1;
            obj.m_k = 0;
            obj.W = 0;
            obj.strobe = 0;
            obj.zc_idx = 0;
            obj.v_i = 0;
            obj.last_sample = 0;
            obj.last_idx = 0;
            obj.mu = 0;
            obj.v = 0;
            obj.sample = 0;
            obj.sample_zc = 0;
            obj.delay_line = zeros(1000000000, 1);
            obj.delay_idx = 0;
            obj.i = 1;
        end

        function [out,out2,out3, out4, out5] = getOutputSizeImpl(obj)
            % Return size for each output port
            out = [1 1];
            out2 = [1 1];
            out3 = [1 1];
            out4 = [1 1];
            out5 = [1 1];
            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end


        function [out,out2,out3, out4, out5] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = "double";
            out2 = "double";
            out3 = "double";
            out4 = "double";
            out5 = "double";
            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        function [out,out2,out3, out4, out5]    = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = false;
            out2 = false;
            out3 = false;
            out4 = false;
            out5 = false;
            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        

        function [out,out2,out3, out4, out5] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;
            out2 = true;
            out3 = true;
            out4 = true;
            out5 = true;
            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end

        function [sz,dt,cp] = getDiscreteStateSpecificationImpl(obj,name)
            % Return size, data type, and complexity of discrete-state
            % specified in name
            sz = [1 1];
            dt = "double";
            cp = false;
        end
    end 

    methods(Access=private)
        function output = interpolateLinear(~, input, m_k, mu)
            if (mu < 0)
                m_k = m_k - 1;
                mu = mu + 1;
            elseif (mu >= 1) 
                m_k = m_k + 1;  
                mu = mu - 1;
            end
            output = mu * input(m_k + 1) + (1 - mu) * input(m_k);
        end
    end
end
