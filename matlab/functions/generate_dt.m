function tau = generate_dt(...
    dx, ... minimum interval [m]
    v0, ... initial feedrate [m/s]
    a_max ... maximum acceleration [m/s^2]
)
% Calculate the minimum delta t for the PVT simulation

tau = 1/a_max * (-v0 + sqrt(v0 * v0 + 2 * a_max * dx));


end