function [v_line, vValid_line] = VelocityOneLine(s, t, v0, a)
% Compute the velocity for one slice of the dwell time
% Inputs:                                             
%      s: distance between two dwell points [counts]                     
%      t: one slice of the dwell time [s]
%     v0: the initial speed of the stage [counts]
%      a: acceleration [counts/s^2]


% Initialize the velocity to 0
v_line = zeros(length(t),1);
vValid_line = false(length(t),1);

% Calculate the velocity for each dwell point
for k = 1:length(t)
    % v0 is used if it is the first point
    if k==1
        v_pre = v0;
    else
        v_pre = v_line(k-1);
    end
        
    % Compute the velocity
    % Acceleration
    if s/t(k) > v_pre
        delta = (v_pre + a * t(k)).^2 - (v_pre.^2 + 2*a*s);
        if(delta >= 0)
            v_line(k) = Vk1(v_pre, a, t(k), delta);
            vValid_line(k) = true;
        else
            v_line(k) = Vk3(v_pre, a, s);
            vValid_line(k) = false;
        end
    % Deacceleration
    elseif s/t(k) < v_pre
        delta = (v_pre - a * t(k)).^2 - (v_pre.^2 - 2*a*s);
        [v_line(k), vValid_line(k)] = Vk2(v_pre, -a, t(k), delta, s);
    % Constant
    else
        v_line(k) = v_pre;    
    end    
end

v_line = [v_line;0];

end

%% Three velocity solutions
function v1 = Vk1(v_pre, a, tk, delta)
v1 = round((v_pre + a * tk) - sqrt(delta));
end

function [v2, v2Valid] = Vk2(v_pre, a, tk, delta, s)
if(delta >= 0)
    v2 = round((v_pre + a * tk) + sqrt(delta));
    if(v2<0)
       v2 = Vk3(v_pre, a, s); 
       v2Valid = false;
    else
        v2Valid = true;
    end
else
    v2 = Vk3(v_pre, a, s); 
    v2Valid = false;
end

end

function v3 = Vk3(v_pre, a, s)
v3 = round(sqrt(v_pre^2 + 2*a*s));
end