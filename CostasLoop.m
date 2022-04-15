classdef CostasLoop < matlab.System
    % Costas Loop for frequency and phase recovery

    % Public, tunable properties
    properties
        alpha = 0.25;
        beta = 0.25 * 0.25 / 4;
        lpf_coeffs =  [0.078989, 0.085868, 0.091518, 0.095721, 0.098311, 0.099186, 0.098311, 0.095721, 0.09151, 0.085868, 0.078989];
        Fc = 8e3;
        Fs = 48e3;
        REF_PERIOD = 1e6/8e3;
        SAMPLE_PERIOD = 1e6/48e3;
        intgralf = 1.2 * 0.25 / 1e6/8e3;
    end

    properties(DiscreteState)
        phase;
        period;
        f;
        error_int;
    end

    % Pre-computed constants
    properties(Access = private)
        buf_lpf_I;
        buf_idx_I;
        buf_lpf_Q;
        buf_idx_Q;
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants

        end

        function [S_I,S_Q,lock, ask, error] = stepImpl(obj,input)
            output = zeros(length(input), 1);

            for i=1:length(input)
                S = input(i);
                obj.f = obj.f + obj.SAMPLE_PERIOD * 2 * pi / obj.period;
    
                if(obj.f > 2 * pi)
                    obj.f = obj.f - 2 * pi;
                end

                I = cos(obj.f + obj.phase);
                Q = -sin(obj.f + obj.phase);
                S_I = obj.I_filter_step(S * I);
                S_Q = obj.Q_filter_step(S * Q);
                error = sign(S_I) * S_Q;
                output(i) = S_I;
                obj.error_int = obj.error_int + error * obj.SAMPLE_PERIOD;
                error = error + obj.error_int * obj.intgralf;
                obj.phase = obj.phase + obj.alpha * error;
                obj.period = obj.period - obj.beta * error;
                lock = S_I * S_I - S_Q * S_Q;
                ask = S_I * S_I - S_Q * S_Q;
            end
            
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.error_int = 0;
            obj.period = 1e6 / obj.Fc;
            obj.f = - (1e6/obj.Fs)* 2 * pi / (1e6/obj.Fc); 
            obj.phase = pi/2;

            % Simple FIR filter stuff
            obj.buf_lpf_I = zeros(length(obj.lpf_coeffs),1);
            obj.buf_lpf_Q = zeros(length(obj.lpf_coeffs),1);
            obj.buf_idx_I = 1;
            obj.buf_idx_Q = 1;
        end

        function res = I_filter_step(obj, val)
            obj.buf_lpf_I(obj.buf_idx_I) = val;
            obj.buf_idx_I = obj.buf_idx_I + 1;
            obj.buf_idx_I = mod(obj.buf_idx_I, length(obj.lpf_coeffs) + 1);
            if(obj.buf_idx_I == 0)
                obj.buf_idx_I = 1;
            end

            ret = 0;
            index = obj.buf_idx_I;
            for i=1:length(obj.lpf_coeffs)
                index = index - 1;
                if(index < 1)
                    index = length(obj.lpf_coeffs);
                end
                ret = ret + obj.buf_lpf_I(index) * obj.lpf_coeffs(i);
            end
            res = ret;
        end

        function res = Q_filter_step(obj, val)
            obj.buf_lpf_Q(obj.buf_idx_Q) = val;
            obj.buf_idx_Q = obj.buf_idx_Q + 1;
            obj.buf_idx_Q = mod(obj.buf_idx_Q, length(obj.lpf_coeffs) + 1);
            if(obj.buf_idx_Q == 0)
                obj.buf_idx_Q = 1;
            end
            ret = 0;
            index = obj.buf_idx_Q;
            for i=1:length(obj.lpf_coeffs)
                index = index - 1;
                if(index < 1)
                    index = length(obj.lpf_coeffs);
                end
                ret = ret + obj.buf_lpf_Q(index) * obj.lpf_coeffs(i);
            end
            res = ret;
        end
    end
end
