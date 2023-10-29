
function [result] = LZ_Complexity_Norm(D)
    result = lz_complexity_2D(D) / pci_norm_factor(D);
end

%------------------------------------------------------------------------
% Function to calculate the Lempel-Ziv algorithmic complexity (Lempel and
% Ziv 1976) on a binarised, 2D matrix of Significant Sources SS(x,t) for
% calculation the Perturbational Complexity Index as in Casali et al.
% (2013). The functions used within it follow the algorithm diagram
% available in the Supplementary Information of Casali et al. (2013).
%
% INPUT
% - D: binarised, 2D matrix of significant sources
% 
% OUTPUT
% - result: normalised Lempel-Ziv complexity of D, i.e., PCI value
%
% Adapted from a Python Script from Tomas Berjaga Buisan
% https://github.com/tomasberjaga/Master-Thesis/tree/main
% Adapted to Matlab by Mariana Henriques 2023
% mariana.m.henriques@tecnico.ulisboa.pt
%------------------------------------------------------------------------

function S = pci_norm_factor(D) % function to normalise complexity by source entropy
    L = numel(D);
    p1 = sum(D(:) == 1) / L; % fraction of 1's in the matrix
    p0 = 1 - p1; % fraction of 0's
    
    if p1 * p0
        H = -p1 * log2(p1) - p0 * log2(p0); % source entropy H(L)
        if H < 0.08
            H = 0.08; % condition to avoid numerical instabilities and artificially high PCI values
        end
    else
        H = 1;
    end
    S = (L * H) / log2(L);
end


function c = lz_complexity_2D(D)
    if max(D(:)) == 0
        c = 0;
        return;
    end

    % initialize
    [L1, L2] = size(D);
    c = 1;
    r = 1;
    q = 1;
    k = 1;
    i = 1;
    stop = false;

    % convert each column to a sequence of bits
    bits = cell(1,L2);
    for y = 1:L2
        bits{y} = D(:,y)';
    end

    % action to perform every time it reaches the end of the column
    function [r, c, i, q, k, stop] = end_of_column(r, c, i, q, k, stop)
        r = r + 1;
        if r > L2
            c = c + 1;
            stop = true;
        else
            i = 0;
            q = r - 1;
            k = 1;
        end
    end


    % main loop of the algorithm
    while ~stop
        if q == r
            a = i + k - 1;
        else
            a = L1;
        end

        % Matlab wants to use "contains" for readability but it doesn't
        % work well that way
        found = ~isempty(strfind(bits{q}(1:a),bits{r}(i+1:i+k)));

        if found
            k = k + 1;
            if i + k > L1
                [r, c, i, q, k, stop] = end_of_column(r, c, i, q, k, stop);
            end
        else
            q = q - 1;
            if q < 1
                c = c + 1;
                i = i + k;
                if i + 1 > L1
                    [r, c, i, q, k, stop] = end_of_column(r, c, i, q, k, stop);
                else
                    q = r;
                    k = 1;
                end
            end
        end
    end
end
