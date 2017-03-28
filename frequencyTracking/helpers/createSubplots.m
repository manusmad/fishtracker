function handles = createSubplots(handles)
% CREATESUBPLOTS Creates subplot grid based on number of channels
% 
% Manu S. Madhav
% 2016

    if isfield(handles,'meta')
        nCh = handles.meta.nCh;
    else
        nCh=0;
    end
    
    if nCh
        if isfield(handles,'hSub')
            delete(handles.hSub);
            handles = rmfield(handles,'hSub');
        end
        handles.hSub = gobjects(nCh,1);
        
        n = ceil(sqrt(nCh));
        margin = 0.02;
        w = (1 - (n+1)*margin)/n;
        h = (1 - (n+1)*margin)/n;
        
        for k = 1:nCh
            [r,c] = find(~(flipud(reshape(1:n^2,n,n)')-k),1);
            handles.hSub(k) = axes('Parent',handles.multiPlotPanel,...
                'Position',[c*margin + (c-1)*w, r*margin + (r-1)*h, w,h]);
            if r~=1 || c~=1
                set(handles.hSub(k),'XTick',[],'YTick',[]);
            end
        end        
    end
            
