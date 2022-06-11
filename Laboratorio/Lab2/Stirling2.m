function resultado = Stirling2(n,k)
% Casos base

if n == k || k == 1
    resultado = 1;
else 
    resultado = k * Stirling2(n-1,k) + Stirling2(n-1,k-1);
end

end

