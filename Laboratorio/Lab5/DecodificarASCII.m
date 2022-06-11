function [str] = DecodificarASCII(encripted_str)

str = '';

while encripted_str > 0
    str = [char(int32(mod(encripted_str,256))), str];
    encripted_str = floor(encripted_str/256);
end

end

