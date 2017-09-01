function[]=writedxf(fname,X,Y,Z) 
%
% Given a filename and a 3d line where each line element is 
% specified by X,Y, and Z coordinates it writes a DXF file with the  
% a connected line and N vertices. 
% try at your own risk, refer also to writedxf.m from Greg Siegle
%
fullname=sprintf('%s.dxf',fname);
fid=fopen(fullname,'w');
fprintf(fid,'999\ncreated by Matlab\n 0\nSECTION\n 2\nENTITIES\n 0\n');
for a=1:length(X)-1
      fprintf(fid,'LINE\n 8\n 0\n');
      %create new line element
      fprintf(fid,'10\n %.4f\n 20\n %.4f\n 30\n %.4f\n',X(a),Y(a),Z(a));
      %first coordinate triple - starting point of line-element
      fprintf(fid,'11\n %.4f\n 21\n %.4f\n 31\n %.4f\n',X(a+1),Y(a+1),Z(a+1));      
      %second coordinate triple - ending point of line-element
      fprintf(fid,' 0\n');
end
fprintf(fid,'ENDSEC\n 0\nEOF\n');
fclose(fid);