# Adaptive-nLMS-Filter

***Measure a room impulse response with nLMS filter (DSP project)***

This program was created as a project for a DSP class at Georgia Tech. The task for the project was to create a program to obtain room impulse response measurments using adaptive nLMS filter.  

** clarification for the _scripts_ **
- project2.m:   main script where whole project executed
- nlms_Ed.m:    tgeneral Adaptive nLMS filter 
- noise_nlms.m: specific nLMS filer for noise

** clarification for _project2.m_ scipt **
- Part1: learned room impulse response generation
  - Step1: _simulated_ room impulse respons generation
  - Step2: applying nLMS filter to estimate RIR
  - Step3: speech and music noise generation 
      (+ clean vertion to measure the perfomance)
- Part2: estimation of the delay between speaker and microphone 
         using the sound with different type and level background noise
  
