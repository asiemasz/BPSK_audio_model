%k = 1;
%for i=spb:spb*8:length(rf)
%for j=1:spb:spb*8
%if rf(i+j-1) < 0
%out(k) = 1;
%else
%out(k) = 0;
%end
%k = k+1;
%end
%end
%out(1:24)
out = zeros(length(data),1);
k = 1;
for i=spb/2:spb*8:(length(rx)-spb/2)
for j=0:spb:spb*7
    if rx(i + j) < 0
   fprintf("%d ", 1)
    out(k) = 1;
    else
   fprintf("%d ", 0)
   out(k) = 0;
    end
    k = k+1;
end
end
%out