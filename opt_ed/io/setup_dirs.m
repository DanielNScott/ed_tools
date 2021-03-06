function [ ] = setup_dirs( job_num, niter, fmt, job_wtime, job_mem, partition ...
                         , state_prop, labels, pfts, verbose )
%SET_DIRS Summary of this function goes here
%   Detailed explanation goes here

dir = ['./job_' num2str(job_num,fmt)];                         % Set particle directory
vdisp(['Current loc: ', pwd]  ,1,verbose);
vdisp(['Setting up dir: ' dir],1,verbose);

cd(dir)
vdisp(['niter being passed: ' num2str(niter)],1,verbose)

file_list = {'./run_flag.mat'...                               % In case it's accidentally there
             './job_obj.mat' ...                               % Avoid accidental re-read
            ,'./job_out.mat' ...                               % Avoid accidental re-read
            ,'./job_stats.mat'};                               % Avoid accidental re-read

for fnum = 1:numel(file_list)
   ifile = file_list{fnum};
   if exist(ifile,'file')                                      % If old data exists...
      delete(ifile)                                            % Delete it ...
      vdisp(['file removed: ' ifile],1,verbose)                % ... and notify!
   else
      vdisp(['file did not exist: ' ifile],1,verbose)          %
   end
end

if verbose >= 1; disp('Writing config.xml...'); end
write_config_xml(state_prop, labels, pfts);

%vdisp('Writing job config: ',1,verbose);
%save([pwd '/job_config.mat'],'job_num','niter')
run_flag_fid = fopen('run_flag.txt','wt');
fclose(run_flag_fid);


vdisp('Calling set_scheduler_opts...',1,verbose)
job_name = ['job_', num2str(job_num,fmt)];
set_scheduler_opts(job_name,job_wtime,job_mem,niter,partition)

vdisp('Moving one directory up...',1,verbose)
cd('../')

end

function [ ] = set_scheduler_opts( job_name, time, mem, niter, partition )
%SET_SCHEDULER_OPTS Summary of this function goes here
%   Detailed explanation goes here

fname = 'wrap_script.sh';
lnums = [12,13,14,15];


A = regexp( fileread(fname), '\n', 'split'); 

A(lnums) = {['#SBATCH -t ' num2str(time*niter)] ...
           ,['#SBATCH -p ' partition] ...
           ,['#SBATCH --mem=' num2str(mem)] ...
          ,['#SBATCH -J ' job_name]};
        
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

end

