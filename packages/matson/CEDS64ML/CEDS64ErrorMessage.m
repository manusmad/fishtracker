%{
    Copyright (C) Cambridge Electronic Design Limited 2014
    Author: James Thompson
    Web: www.ced.co.uk email: james@ced.co.uk, softhelp@ced.co.uk

    This file is part of CEDS64ML, a MATLAB interface to the SON64 library.

    CEDS64ML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CEDS64ML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CEDS64ML.  If not, see <http://www.gnu.org/licenses/>.
%}

function [ ] = CEDS64ErrorMessage( iErrorCode )
%CEDS64ERRORMESSAGE This function converts integer error codes into warnings
%describing the errors in plain english.
%   [ ] = CEDS64ErrorMessage( iErrorCode )
%   Inputs
%   iErrorCode - An negative integer code.
%   Outputs
if (isnumeric(iErrorCode) && iErrorCode < 0)
    switch (iErrorCode)
        case -1
            warning('Error opening file. Possible resons include: the file does not exist, the file is already open in another program, tried to use a file handle out of range, tried to open more than 8 files at once, used a file handle that has no file associated to it  ');
        case -2
            warning('failed to allocate a disk block');
        case -3
            warning('Timeout, try again');
        case -4
            warning('RESERVED');
        case -5
            warning('File already in use elsewhere');
        case -6
            warning('RESERVED');
        case -7
            warning('RESERVED');
        case -8
            warning('Ran out of memory whilst reading a 32-bit file');
        case -9
            warning('Channel does not exist');
        case -10
            warning('Channel is already in use');
        case -11
            warning('Invalid channel type');
        case -12
            warning('Attempted to read past the end of the file');
        case -13
            warning('Wrong type of file');
        case -14
            warning('Request is outside extra data region');
        case -15
            warning('RESERVED');
        case -16
            warning('RESERVED');
        case -17
            warning('Read error');
        case -18
            warning('Write error');
        case -19
            warning('The file or the data is corrupted');
        case -20
            warning('Attempted to access data before the start of the file');
        case -21
            warning('Attempted to write to read only file');
        case -22
            warning('Bad parameter');
        case -23
            warning('Attempted to write over data when not permitted');
        case -24
            warning('The file is bigger than the header says; maybe not closed correctly');
        otherwise
            warning('unknown error');
    end
end
end

