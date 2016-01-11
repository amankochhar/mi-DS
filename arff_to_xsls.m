clc; clear;

[filename,pathname]=uigetfile('.arff','Please select file to convert');
full_fn=strcat(pathname,filename);
fid=fopen(full_fn);

for i=1:1e3
    line=fgetl(fid);
    if strcmp(line,'@data');        
        break
    end
end

for j=1:1000
    line=fgetl(fid);
    if line==-1
        break
    end
    start_index=regexp(line,'"');
   
    data_line=line(start_index(1)+1:start_index(2)-2);
    
    data_line=strcat(',',data_line,',');
    comma_index=regexp(data_line,',');
    
    for i=1:numel(comma_index)-1
        data=data_line(comma_index(i)+1:comma_index(i+1)-1);
         
        if ~isempty(regexp(data,'n'))
            mera_data(1,i)=str2num(data(3:end));
        else
            mera_data(1,i)=str2num(data);   
        end
    end
    class=str2num(line(start_index(2)+2:end));
    mera_data_res=reshape(mera_data,166,[])';    
    [nrow,~]=size(mera_data_res);
    mera_data_res=[ones(nrow,1)*j,mera_data_res,ones(nrow,1)*class];
    all_data{j,1}=mera_data_res;
    mera_data_res=[];
    mera_data=[];
end

all_data_mat=cell2mat(all_data);
out_fn=strcat(filename(1:end-5),'.xls');
xlswrite(out_fn,all_data_mat);
fclose('all');
