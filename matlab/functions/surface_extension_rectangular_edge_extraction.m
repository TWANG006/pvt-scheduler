function idEdge = surface_extension_rectangular_edge_extraction(Zext)
% Function
%   id_edge = Surface_Extension_EdgeExtraction(Z_ext)
% Purpose
%   Find edge points in the Z_ext, which contains NaN as the extension area
% Inputs:
%   Z_ext: initial extended surface with NaNs
% Outputs:
%   id_edge: ids with the same size as Z_ext, with edge points = 1 and the
%   other positions = 0

idEdge = ~isnan(Zext);
[idy, idx] = find(idEdge==1);

h = size(Zext, 1); ... height of Z_ext
w = size(Zext, 2); ... width of Z_ext

for k = 1:length(idy)
    count = 0;
    for i = -1:1
        for j = -1:1
            if (~(i==0 && j==0))
                idi = idy(k)+i;    ... neighbor y id
                idj = idx(k)+j;    ... neighbor x id
                    
                if (0<idi && idi<=h && 0<idj && idj<=w)
                    if(isnan(Zext(idi, idj)))
                        count = count+1;
                    end
                end
            end
        end
    end
    if (count==0)
        idEdge(idy(k), idx(k)) = 0;
    end       
end

end