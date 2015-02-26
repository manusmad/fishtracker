function [fid,dir,infile]=get_new_file(dir)
file_flag=input('enter 1 for new directory, 0 for same directory')
if file_flag==1
dir = input('Please input the file directory: ', 's');
end

infile = input('Please input filename: ', 's');

	totalfile = strcat(dir, infile)
	fid=fopen(totalfile, 'r')