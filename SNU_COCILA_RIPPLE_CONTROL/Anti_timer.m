function [] = Anti_timer(mTimer,~)

app =mTimer.UserData.Outtimer.UserData.App;


if app.Anti_end
    stop(mTimer);
end


disp('anti_timer_running')


if app.anti_stim_ready 

[count,timestamps,waveforms,units] = xippmex('spike',app.RecChSpinner.Value);


if sum(units{1,1}==app.unit)> 0  

    if app.first_time_anti

        mTimer.UserData.current_time = xippmex('time')/30;

        T = timer('StartDelay',app.StimdelaySpinner.Value/1000);
        T.TimerFcn = @anti_stim;
        T.UserData.spiketimer = mTimer.UserData.spiketimer;
        T.UserData.Outtimer = mTimer.UserData.Outtimer;
        start(T);
        app.first_time_anti = 0;
    end

    sorted_waveforms = cellfun(@(x,y) x(y==app.unit,:),waveforms,units,'UniformOutput',false);
    valid_ind = logical(cellfun(@(x) length(x), sorted_waveforms));
    sorted_waveforms = sorted_waveforms(valid_ind);

    hold(app.UIAxes_2,"on");
    cellfun(@(x,y) plot(app.UIAxes_2,linspace(-app.StimdelaySpinner.Value+( (y/30)-mTimer.UserData.current_time)...
        ,-app.StimdelaySpinner.Value+( (y/30)-mTimer.UserData.current_time)+1700,52),x'),num2cell(sorted_waveforms{:}',1),num2cell(timestamps{:},1))
    xline(app.UIAxes_2,0)
end
end

end