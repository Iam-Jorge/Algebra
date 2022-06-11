function [T] = CodificarASCII(str)
%       CodificarASCII recibe una cadena de texto ('str') y devuelve
%       la cadena en decimal tras aplicar una codificación ASCII.
%       T = Cadena en decimal tras la codificación ASCII.

M = uint8(str);

% Los distintos caracteres en binario:
%dec2bin(M)

B = sym(256);
T = sym(M(length(str)));
for i=length(str)-1:-1:1
    T = T + M(i)*B;
    B = 256*B;
end

% El texto en binario:
%dec2bin(T)

end

