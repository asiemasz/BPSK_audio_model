out = zeros(length(data),1);
k = 1;
for i=spb/2:spb*8:(length(rx)-spb/2)
    if(i == spb/2)
    if(rx(i) < 0)
        fprintf("%d ", 1)
        out(k) = 1;
    else
        out(k) = 0;
        fprintf("%d ", 0)
    end
    k = k+1;
for j=spb:spb:spb*7
    if rx(i + j)*rx(i + j - spb) < 0
   fprintf("%d ", 1)
    out(k) = 1;
    else
   fprintf("%d ", 0)
   out(k) = 0;
    end
    k = k+1;
end
else
    for j=0:spb:spb*7
    if rx(i + j)*rx(i + j - spb) < 0
   fprintf("%d ", 1)
    out(k) = 1;
    else
   fprintf("%d ", 0)
   out(k) = 0;
    end
    k = k+1;
    end
end
end

%out