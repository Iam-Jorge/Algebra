function result = FibonacciA(n)

fibonacci(1)=1;
fibonacci(2)=1;

for i=3:n
    fibonacci(i)=fibonacci(i-1)+fibonacci(i-2);
end
    result = fibonacci(n)
end

