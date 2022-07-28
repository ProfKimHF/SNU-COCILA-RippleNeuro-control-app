function t = create_trialDAQ_timer() %inner timer
period_seconds = .001;
t=timer;
t.UserData.trial_end = 0;
t.UserData.Trial = 0;
t.TimerFcn = @trial_DAQ; 
t.Period = period_seconds;
t.ExecutionMode = 'fixedSpacing';
t.StopFcn = @reset_trial;
end

