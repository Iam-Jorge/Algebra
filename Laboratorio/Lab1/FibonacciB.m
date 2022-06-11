function result = FibonacciB(n)

result = 0;
if n == 1
    result = 1;
elseif n == 2
    result = 1;
else
    result = FibonacciB(n-1) + FibonacciB(n-2)
end

end

