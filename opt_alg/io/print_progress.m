function [ ] = print_progress( iter, niter, acc_rate, accept)
%PRINT_PROGRESS Summary of this function goes here
%   Detailed explanation goes here
   
   frac_complete  = iter/niter;
   tenth_complete = frac_complete*10 == floor(frac_complete*10);
   if tenth_complete
      
      prev_frac = frac_complete*niter - 0.1*niter;
      prev_str  = num2str(prev_frac);
      curr_str  = num2str(frac_complete*niter);
      
      acc_rate_10  = num2str(sum(accept(prev_frac*niter+1:iter)/(0.1*niter)));

      disp( '%---- Progress indication --------------------------------------------%')
      disp([' Iterations ', prev_str, ' through ', curr_str ,' have completed.'])
      disp([' Acceptance rate over all runs: ', num2str(acc_rate)])
      disp([' Acceptance rate /prev 10 runs: ', acc_rate_10])
      disp( '%---------------------------------------------------------------------%')
      disp( ' ')
   end

end

