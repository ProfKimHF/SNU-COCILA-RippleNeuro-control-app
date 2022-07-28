function t = create_Anti_timer() %inner timer
period_seconds = .001;
t=timer;
t.TimerFcn = @Anti_timer; 
t.Period = period_seconds;
t.ExecutionMode = 'fixedSpacing';
t.UserData.waveforms = cell(0,0);
t.UserData.units = cell(0,0);

end

