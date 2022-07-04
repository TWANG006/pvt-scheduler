function v = calculate_pvt_v(t, c)

v = 3 * c(1) * t.^2 + 2 * c(2) * t + c(3);
v = v(:);

end