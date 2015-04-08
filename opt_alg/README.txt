------------------------------------------------------------
   README:
------------------------------------------------------------
- To use the optimization algorithm, one needs the folders opt_alg and misc_routines.
- To use the post processing files (mostly for graphing things) one needs the folders
  plotting_tools and matlab_central


------------------------------------------------------------
To use the optimization framework:
------------------------------------------------------------
1) Put the folders listed above somewhere in your filesystem.

2) Open the files optimize_ed.sh and runopt.sh under opt_alg
   In optimize_ed.sh...
   2.1) Edit the paths for the folders opt_alg and misc_routines.
   2.2) Edit the call to matlab if it is not working properly, though it should.
   In runopt.sh...
   2.3) Edit the queue system wrapper commands as necessary. (This file is a queue system wrapper
         for the file optimize_ed.sh.)

3) Go to the directory from which you'll be running ED.
   3.1) Make a soft link to the executable, and call it 'ed'. If you want to use a different name
        for the executable, you will need to change the way it's called from matlab. This can be 
        found in the file opt_alg/run_model.m
   3.2) Copy the file 'settings.m' from the opt_alg directory to the directory you're in.
   3.3) Copy the files optimize_ed.sh and runopt.sh to the directory you're in.

4) Edit your ED2IN as desired, but turn IDOUTPUT, IQOUTPUT, IYOUTPUT, and ITOUTPUT on.

5) Edit the file settings.m as desired. You can run test optimizations on the rosenbrock 2D function
   to mess around with different settings and get a feel for how everything works if interested.
   
6) To run an optimization on the machine you're logged into, call 'optimize_ed.sh'. To run an 
   optimization via queue, cal 'runopt.sh'. If you append a filename, e.g. './myNewSettings' to the
   call, the optimization algorithm will try to load a file './myNewSettings.m' instead of the default
   'settings.m' in it's configuration.



------------------------------------------------------------
You already know how to get a hold of me:
------------------------------------------------------------
Email me with questions/comments or post them to the github page.
Email : dscott@fas.harvard.edu
Github: https://github.com/DanielNScott/ED_Tools