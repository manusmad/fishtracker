function handles = setRanges(handles,F1,F2,T1,T2)
% SETRANGES Function to set frequency and time ranges
%
% Sets ranges based on edited values of F1,F2,T1,T2
%
% Manu S. Madhav
% 2016

    handles.params.rangeF1 = F1;
    handles.params.rangeF2 = F2;
    handles.params.rangeT1 = T1;
    handles.params.rangeT2 = T2;
    
    set(handles.rangeF1Edit,'String',num2str(F1));
    set(handles.rangeF2Edit,'String',num2str(F2));
    set(handles.rangeT1Edit,'String',num2str(T1));
    set(handles.rangeT2Edit,'String',num2str(T2));

