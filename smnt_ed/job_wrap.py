import subprocess

# Write a function like this called 'main'
def main(job_id, params):
  print 'Anything printed here will end up in the output directory for job #%d' % job_id
  print params

  # Convert the list of parameter values to a string representing a matlab vector
  pstr = '['
  for pval in range(1,len(params))
    pstr = pstr + str(pval) + ','

  pstr[-1] = ']'


  # Call the process; Stdout of .sh process will be captured. 
  job = subprocess.call(['run_job_smnt.sh',pstr], universal_newlines=True)
  objective = float(job.stdout)

  return objective