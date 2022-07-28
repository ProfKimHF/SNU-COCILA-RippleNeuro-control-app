function [] = get_spike(mTimer,~)

app =mTimer.UserData.Outtimer.UserData.App;
disp('get_spike_running')

toc
if toc < app.RefractorydurSpinner.Value/1000

    [count,timestamps,waveforms,units] = xippmex('spike',app.RecChSpinner.Value);
    if size(waveforms{1,1},1)~=0
        mTimer.UserData.waveforms = [mTimer.UserData.waveforms waveforms];
        mTimer.UserData.units = [mTimer.UserData.units units];



        sorted_waveforms = cellfun(@(x,y) x(y==app.unit,:),waveforms,units,'UniformOutput',false);
        valid_ind = logical(cellfun(@(x) length(x), sorted_waveforms));
        sorted_waveforms = sorted_waveforms(valid_ind);

        cellfun(@(x,y) plot(app.UIAxes_2,linspace(y/30-app.anti_stim_time,y/30-app.anti_stim_time+1700,52),x'),...
            num2cell(sorted_waveforms{:}',1),num2cell(timestamps{:},1));
    end

else
    stop(mTimer);
    app.anti_stim_ready = 1;
    app.first_time_anti = 1;

end
