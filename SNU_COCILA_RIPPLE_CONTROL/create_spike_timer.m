function t = create_spike_timer() %inner timer
period_seconds = .001;
t=timer;
t.TimerFcn = @get_spike; 
t.Period = period_seconds;
t.ExecutionMode = 'fixedSpacing';
t.UserData.waveforms = cell(0,0);
t.UserData.units = cell(0,0);
t.StartFcn = @(src,evt)tic;

end

