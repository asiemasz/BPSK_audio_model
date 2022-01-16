classdef CostasLoop < matlab.System
    % Costas Loop for frequency and phase recovery

    % Public, tunable properties
    properties
        alpha = 0.1;
        beta = 0.1 * 0.1 / 4;
        A = [1.0 -0.5095254494944288];
        B = [0.2452372752527856 0.2452372752527856];
        FC = 8000;
        FS = 48000;
    end

    properties(DiscreteState)
        omega;
        error;
        phase;
        errorTot;
    end

    % Pre-computed constants
    properties(Access = private)
        buf_A_I;
        buf_B_I;
        pos_A_I;
        pos_B_I;
        n_A_I;
        n_B_I;
        buf_A_Q;
        buf_B_Q;
        pos_A_Q;
        pos_B_Q;
        n_A_Q;
        n_B_Q;
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants

        end

        function [carrier, freq, phase, error, errorTot] = stepImpl(obj,input)
            % Implement algorithm. Caplculate y as a function of input u and
            % discrete states.
            obj.phase = obj.phase + obj.omega;
            obj.phase = obj.phase + obj.alpha * obj.error;

            obj.omega = obj.omega + obj.beta * obj.error;

            freq = obj.omega * obj.FS / (2 * pi);
            if(obj.phase > 2*pi)
                obj.phase = obj.phase - 2*pi;
            end
            
            si = cos(obj.phase);
            sq = -sin(obj.phase);

            sim = si*input;
            sqm = sq*input;
            sim = obj.I_filter_step(sim);
            sqm = obj.Q_filter_step(sqm);

            obj.error = sim * sqm;

            carrier = si;
            phase = obj.phase;
            obj.errorTot = obj.errorTot + obj.error;
            error = obj.error;
            errorTot = obj.errorTot;
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            
            %Simple stepping filter stuff
            obj.n_A_I = length(obj.A) - 1;
            obj.buf_A_I = zeros(obj.n_A_I);
            obj.n_B_I = length(obj.B) - 1;
            obj.buf_B_I = zeros(obj.n_B_I);
            obj.pos_A_I = 0;
            obj.pos_B_I = 0;
            obj.n_A_Q = length(obj.A) - 1;
            obj.buf_A_Q = zeros(obj.n_A_Q);
            obj.n_B_Q = length(obj.B) - 1;
            obj.buf_B_Q = zeros(obj.n_B_Q);
            obj.pos_A_Q = 0;
            obj.pos_B_Q = 0;

            obj.errorTot = 0;
            obj.error = 0;
            obj.phase = 0;
            obj.omega = 2*pi*obj.FC/obj.FS;
        end

        function res = I_filter_step(obj, val)
            acc = obj.B(1) * val;

            for i = 1:obj.n_B_I 
                p = mod((obj.pos_B_I + obj.n_B_I - i), obj.n_B_I); 
                acc = acc + obj.B(i+1) * obj.buf_B_I(p+1);
            end

            for i = 1:obj.n_A_I
                p = mod((obj.pos_A_I + obj.n_A_I - i), obj.n_A_I); 
                acc = acc - obj.A(i+1) * obj.buf_A_I(p+1);
            end   

            if obj.n_B_I > 0
                obj.buf_B_I(obj.pos_B_I+1) = val;
                obj.pos_B_I = mod(obj.pos_B_I + 1, obj.n_B_I);
            end

            if obj.n_A_I > 0
                obj.buf_A_I(obj.pos_A_I+1) = val;
                obj.pos_A_I = mod(obj.pos_A_I + 1, obj.n_A_I);
            end

            res = acc;
        end

        function res = Q_filter_step(obj, val)
            acc = obj.B(1) * val;

            for i = 1:obj.n_B_Q 
                p = mod((obj.pos_B_Q + obj.n_B_Q - i), obj.n_B_Q); 
                acc = acc + obj.B(i+1) * obj.buf_B_Q(p+1);
            end

            for i = 1:obj.n_A_Q
                p = mod((obj.pos_A_Q + obj.n_A_Q - i), obj.n_A_Q); 
                acc = acc - obj.A(i+1) * obj.buf_A_Q(p+1);
            end   

            if obj.n_B_Q > 0
                obj.buf_B_Q(obj.pos_B_Q+1) = val;
                obj.pos_B_Q = mod(obj.pos_B_Q + 1, obj.n_B_Q);
            end

            if obj.n_A_Q > 0
                obj.buf_A_Q(obj.pos_A_Q+1) = val;
                obj.pos_A_Q = mod(obj.pos_A_Q + 1, obj.n_A_Q);
            end

            res = acc;
        end
    end
end
