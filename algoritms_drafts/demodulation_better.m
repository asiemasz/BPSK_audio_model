out = zeros(length(data),1);
k = 1;
for i = 1:spb*8:length(rx)
    for j = 0:spb:spb*7
        if sum(rx(i+j:i+j+spb-1)) < 0
            fprintf("%d ", 1);
            out(k) = 1;
        else
            fprintf("%d ", 0);
            out(k) = 0;
        end
        k = k+1;
    end
end