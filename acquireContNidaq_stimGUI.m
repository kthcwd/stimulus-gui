function acquireContNidaq_stimGUI(src,event,handles)

global nc

[chanIn,~] = getNidaqSettings(handles);

if mod(nc.counter,50)==0
    disp('acquiring continuously')
end

d = read(nc.s,'all');
if ~isfield(nc,'acq_varnames')
    nc.acq_varnames = d.Properties.VariableNames;
end
% data_format = '%f\t';
% % st = sprintf('d.(%s)',nc.acq_varnames{1});
% for ii = 1:length(chanIn)-1
%     data_format = strcat(data_format,data_format);
% end

t = table2array(d);

% dlmwrite(nc.fid,t,'-append','delimiter','\t');
writematrix(t,nc.fid,'Delimiter','tab','WriteMode','append')

% fprintf(nc.fid,data_format,t);

% if length(chanIn)==3
%     d = read(nc.s,'all');
%     fprintf(nc.fid,'%f\t%f\t%f\n',d.Data');
% else
%     d = read(nc.s,'all');
%     n = d.Properties.VariableNames{1};
%     fprintf(nc.fid,'%f\t%f\n',[seconds(d.Time),d.(n)]);
% end