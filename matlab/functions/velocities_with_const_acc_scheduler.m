function v = velocities_with_const_acc_scheduler(...
    p,    ... points on the tool path
    t,    ... dwell time to travel each two tool path points
    vmax, ... max feedrate of the stage
    amax  ... max acceleration of the stage
)
%-------------------------------------------------------------------------%
% @purpose
%   Compute the feedrates for each point on the tool path with the constant
%   acceleration model defined as                                           
%                       s1 + s2 = s                                          
%                       t1 + t2 = t                                         
%                       s1 = (v_k^2 - v_k-1^2) / 2a                         
%                       t1 = (v_k - v_k-1) / a                              
%                       s2 = v_k.t2
% @returns
%    v: the calculated velocities for each path points
%   t1: the time needed to acc/dcc for each interval
% @reference
%   Zhou, L., Xie, X., Dai, Y., Jiao, C., & Li, S. (2009). 
%   Realization of velocity mode in flat optics machining using ion beam. 
%   J. Mech. Eng, 45(7), 152-156.
%-------------------------------------------------------------------------%

%% 1. calculate the intervals between each two consecutive tool path points
s = diff(p);
% ds = 0 * s;
v = 0 * p;
% t1 = 0 * t;
% t2 = 0 * t;

%% 2. call the calculate_feedrate function
for k = 1: length(t)
    % calculate the velocities
    v(k + 1) = calculate_velocity(...
        s(k), ...
        t(k), ...
        v(k), ...
        amax  ...
    );       
end

v(1) = v(2); % update the initial velocity

% calculate again using the updated v0
for k = 1: length(t)    
    v(k + 1) = calculate_velocity(...
        s(k), ...
        t(k), ...
        v(k), ...
        amax  ...
    );       
end


%% 3. constrain the max velocities
v(v > vmax ) = vmax;
v(v < -vmax) = -vmax;


end


function v = calculate_velocity(...
    sk, ... displacement
    tk, ... time
    v0,... initial velocity
    a  ... acceleration
)

% it is acceleration
if sk / tk > v0
    v = vk1(v0, a, tk, sk);    
% it is decceleration
elseif sk / tk < v0
    v = vk2(v0, a, tk, sk);
% it is constant velocity
else
    v = v0;    
end

end


function v = vk1(v0, a, tk, sk)

delta = (v0 + a * tk).^2 - (v0.^2 + 2 * a * sk);

if delta >= 0
    v = v0 + a * tk - sqrt(delta);
else
    v = vk3(v0, a, sk);
end

end


function v = vk2(v0, a, tk, sk)

delta = (v0 - a * tk).^2 - (v0.^2 - 2 * a * sk);

if delta >= 0
    v = v0 - a * tk + sqrt(delta);
else
    v = vk3(v0, -a, sk);
end

end


function v = vk3(v0, a, sk)
v = sqrt(v0.^2 + 2 * a * sk);
end