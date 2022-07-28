function reset_trial(mTimer,~)

%%% Innertimer_stopfunction 
%%% Input: mTimer: reference to timer object
%%% This function is automatically called when inner timer stopped. 

mTimer.UserData.trial_end = 0; % when inner timer ends, set the trial_end to 0; this is important variable for inner timer
