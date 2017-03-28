function out = isInRange(handles,time,freq)
% ISINRANGE Is a point within the plot range?
%
% Returns 1 if (time, freq) is within the plot range
% (handles.rangeT1,handles.rangeT2) and (handles.rangeF1,handles.rangeF2),
% else 0.
%
% Manu S. Madhav
% 2016

out = time>=handles.params.rangeT1 && time<= handles.params.rangeT2 && freq >= handles.params.rangeF1 && freq <= handles.params.rangeF2;      