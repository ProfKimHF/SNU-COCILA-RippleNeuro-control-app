function t = background_worker_start(app,start_ECODE,end_ECODE)
%%% Background worker  
%%% Input: 
%%% start_ECODE: start ecode for the trial
%%% end_ECODE: end ecode for the trial
%%% This function sets the variables for timers and starts them

%start_ECODE = 0;
%end_ECODE = 15;
addpath 'C:\Program Files (x86)\Ripple\Trellis\Tools\xippmex'
t1 = create_trialDAQ_timer(); % create inner timer
t2 = create_Anti_timer();
t3 = create_spike_timer();
t = create_DAQ_timer(t1,t2,start_ECODE,end_ECODE,app); %create outer timer 
t1.UserData.Outtimer = t; % reference to the inner timer
t2.UserData.Outtimer = t;
t2.UserData.Outtimer = t;
t3.UserData.Outtimer = t;
t2.UserData.spiketimer = t3;
start(t); % start the timers
end