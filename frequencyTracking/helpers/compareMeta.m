function ret = compareMeta(meta1,meta2)
% COMPAREMETA Compares two metadata structures
%
% Returns 1 if the structures are the same, else returns 0.
%
% Manu S. Madhav
% 2016

    fields1 = sort(fieldnames(meta1));
    fields2 = sort(fieldnames(meta2));
    ret = isequal(sort(fields1),sort(fields2));
    
    % Check if both datasets are from the same source file.
    if ret
        if isfield(meta1,'sourceFile')
            if ~strcmp(meta1.sourceFile,meta2.sourceFile)
                ret = 0;
            end
        else
            ret = 0;
        end
    end