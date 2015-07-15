function [ ] = append_ref( refdir )
%APPEND_REF Appends the necessary fields to the hist structure for reference plots to be made.
%   Input: 
%      refdir: The name of the directory in which a reference simulation has been run.

if ~strcmp(refdir(end),'/')
   refdir(end+1) = '/';
end

cd(refdir)
fake_pso_task(refdir)

load('../opt.mat')

correct = 0;
while ~ correct
   state_ref = input('Please enter a matrix of reference parameter values now...\n');
   disp('You''ve entered:')
   disp(state_ref)
   confirm = input('Is this what you want?\n Please enter a string ''yes'' or string ''no''.\n');
   if strcmp(confirm,'yes')
      correct = 1;
   elseif strcmp(confirm,'no')
      disp('Canceling...')
   else
      disp('Please enter either ''yes'' or ''no'' (as strings!)...')
   end
end

load('particle_out.mat')
load('particle_stats.mat')

hist.out_ref = out;
hist.stats.ref = stats;
hist.state_ref = state_ref;

clear out stats state_ref confirm correct refdir
save('../opt.mat')

end

