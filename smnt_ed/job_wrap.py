import subprocess
import os

def job_wrap(job_id,params):

  params = [params['x'][0],params['y'][0]]

  # Convert the list of parameter values to a string representing a matlab vector
  pstr = '['
  for pval in range(0,len(params)):
    pstr = pstr + str(params[pval]) + ','

  pstr = pstr.rstrip(',') + ']'


  # Call the process; Stdout of .sh process will be captured. 
  job = subprocess.call(['run_job_smnt.sh',str(job_id),pstr], universal_newlines=True)

  fname = 'job_obj_%d.txt' % job_id
  f = open(fname)
  result = f.read()
  result = float(result) 

  return {'job_wrap' : result}



# Write a function like this called 'main'
def main(job_id, params):
  print 'Anything printed here will end up in the output directory for job #%d' % job_id
  print params

  return job_wrap(job_id,params)
