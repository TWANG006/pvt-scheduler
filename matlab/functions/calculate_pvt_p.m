function p = calculate_pvt_p(t, c)

p = c(1) * t.^3 + c(2) * t.^2 + c(3) * t + c(4);
p = p(:);

end