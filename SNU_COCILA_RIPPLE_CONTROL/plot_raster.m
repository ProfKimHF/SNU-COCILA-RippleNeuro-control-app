function plot_raster (outertimer)
outertimer.UserData.plotting =1;
app = outertimer.UserData.App;
tile_ref = app.Rasters{app.Raster_Source}.UserData.t1; %raster tile
Title = app.Rasters{app.Raster_Source}.UserData.Title;
Ref_Ecode = app.Rasters{app.Raster_Source}.UserData.Ref_Ecode;
Mark_Ecode = app.Rasters{app.Raster_Source}.UserData.Mark_Ecode;
Must_Ecode = app.Rasters{app.Raster_Source}.UserData.Must_Ecode;
MustNot_Ecode = app.Rasters{app.Raster_Source}.UserData.MustNot_Ecode;
One_Ecode = app.Rasters{app.Raster_Source}.UserData.One_Ecode; %one of the following Ecodes must exist:
ch = app.Rasters{app.Raster_Source}.UserData.ch;
event_time = outertimer.UserData.Rasters{app.Raster_Source}.Eventtime;
event_code = outertimer.UserData.Rasters{app.Raster_Source}.Eventcode;
spike_time = outertimer.UserData.Rasters{app.Raster_Source}.Spiketime;
mstosec = 1000;
max_histo=[];
offset = length(app.Rasters{app.Raster_Source}.Children)-app.Raster_index.reference; %when Children is added, the index is shifted. This offset accounts for that shift.
RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(app.Raster_index))]),...
    {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
    'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','plotdim','data','config','plotopt','ch_label','DAQ','refresh_text','refresh','reference'}); %label for Children; offset accounted

if app.Rasters{outertimer.UserData.App.Raster_Source}.UserData.Refresh == 0
    app.Rasters{app.Raster_Source}.Children(RI.refresh).ImageSource = "refresh_icon.PNG";
end

if ~ isempty(tile_ref) && ch >0 %&& ch < app.
    
    spike_time_ch = cellfun(@(x) x(ch),spike_time);
    
    for i = 1:tile_ref.GridSize(1)*tile_ref.GridSize(2)
        tmp_t{i} = nexttile(tile_ref,i);
        if ~isempty(Ref_Ecode{i}) && ~isempty(Mark_Ecode{i}) && ~isempty(Must_Ecode{i})
            hold(tmp_t{i},'on');
            
            must_ind = cellfun(@(x) all(ismember(Must_Ecode{i},x)), event_code);
            mustnot_ind = cellfun(@(x) any(ismember(MustNot_Ecode{i},x)),event_code);
            ref_ind = cellfun(@(x) ismember(Ref_Ecode{i},x),event_code);
            mark_ind = cellfun(@(x) ismember(Mark_Ecode{i},x),event_code);
            dup_ind_tmp = cellfun(@(x) length(find(x==outertimer.UserData.Start_ECODE)),event_code);
            dup_ind = dup_ind_tmp == 1;
            if ~isempty(One_Ecode{i})
                one_ind = cellfun(@(x) any(ismember(One_Ecode{i},x)),event_code);
                final_ind = must_ind .* ~mustnot_ind .* one_ind .* ref_ind .* mark_ind .* dup_ind;
            else
                final_ind = must_ind .* ~mustnot_ind .* ref_ind .* mark_ind .* dup_ind;
            end

        else
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i});
                outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i}=[];
            end
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i});
                outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i}=[];

            end
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.histo{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.histo{i});
                outertimer.UserData.Rasters{app.Raster_Source}.histo{i}=[];

            end

            continue;
        end

        if sum(final_ind)==0
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i});
                outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i}=[];

            end
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i});
                outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i}=[];

            end
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.histo{i})
                delete(outertimer.UserData.Rasters{app.Raster_Source}.histo{i});
                outertimer.UserData.Rasters{app.Raster_Source}.histo{i}=[];

            end
          
            continue;
        end

        if    app.Rasters{app.Raster_Source}.UserData.Image_behavioral.UserData %behavior button in Plot options is pushed

            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i})

                delete(outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i})
            end
            if (final_ind(end)==1)
                outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i} = xline(tmp_t{i},0,'--r');
            else
                outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i} = xline(tmp_t{i},0,'--k');
            end
        end
        
        event_time_tmp = event_time(logical(final_ind));
        event_code_tmp = event_code(logical(final_ind));
        spike_time_tmp = spike_time_ch(logical(final_ind));
        

        mark_ind_tmp = cellfun(@(x) find(x==Mark_Ecode{i}), event_code_tmp, 'UniformOutput', false);
        mark_ind = cellfun(@(x) x(1),mark_ind_tmp,'UniformOutput',false);
        mark_time = cellfun(@(x,y) x(y), event_time_tmp, mark_ind);  
        ref_ind = cellfun(@(x) find(x==Ref_Ecode{i}),event_code_tmp , 'UniformOutput', false);
        ref_first_ind = cellfun(@(x) x(1), ref_ind,'UniformOutput',false);
        ref_time = cellfun(@(x,y) x(y), event_time_tmp, ref_first_ind);
        event_time_raw =  cellfun(@(x,y) x-y, event_time_tmp ,num2cell(ref_time) ,'UniformOutput' ,false);
        adj_eventtime =  mark_time-ref_time;
        adj_spiketime = cell2mat(cellfun( @(x,y) x-y, spike_time_tmp,num2cell(ref_time),'UniformOutput',false));
        spike_trial = cell2mat(cellfun(@(x,y) ones(1,length(x))*y,spike_time_tmp,num2cell(1:sum(final_ind)),'UniformOutput',false));
        x_axis_begin = cellfun(@(x,y) x(1)-y , event_time_tmp , num2cell(ref_time));


        yyaxis(tmp_t{i},'right')
        %plot( tmp_t{i},adj_eventtime(mark_ind(1)),app.trial(i) ,'.r');
        if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i})
            delete(outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i});
            outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i}=[];

        end

        if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i})
            delete(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i});
            outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i}=[];

        end
        
        if    app.Rasters{app.Raster_Source}.UserData.Image_behavioral.UserData %behavior button in Plot options is pushed

            outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i} = plot(tmp_t{i},adj_eventtime,1:sum(final_ind),'>r', 'MarkerFaceColor','r', 'MarkerSize',3);
           % if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i})

          %      delete(outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i})
          %  end
          %  outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i} = xline(tmp_t{i},0,'--k');
        end

        if app.Rasters{app.Raster_Source}.UserData.Image_neural.UserData %neural button in Plot options is pushed

            outertimer.UserData.Rasters{app.Raster_Source}.spike_plot{i} = plot(tmp_t{i}, adj_spiketime  , spike_trial, '.k');
        end
        ylim( tmp_t{i},[1 sum(final_ind)*1.5]);


        if ~isempty(adj_spiketime) %PSM edit - 211014: when spike data is not empty
            [hist_spike,~] = histcounts(adj_spiketime,[min(x_axis_begin):1:round(max(adj_spiketime))]);
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.histo{i})
                % outertimer.UserData.Rasters{app.Raster_Source}.histo{i}.Visible = 'off';
                delete(outertimer.UserData.Rasters{app.Raster_Source}.histo{i});
                outertimer.UserData.Rasters{app.Raster_Source}.histo{i}=[];

            end


            yyaxis(tmp_t{i},'left')

            conv_histo = conv(hist_spike/sum(final_ind)*mstosec , app.gauss_value,'same');

            outertimer.UserData.Rasters{app.Raster_Source}.histo{i}= plot(tmp_t{i},min(x_axis_begin):1:round(max(adj_spiketime))-1,conv_histo , '-b');
            outertimer.UserData.Rasters{app.Raster_Source}.histo{i}.LineWidth = 2;

          

            if ~app.Rasters{app.Raster_Source}.UserData.Image_kernel.UserData %kernel button in Plot options is pushed
                outertimer.UserData.Rasters{app.Raster_Source}.histo{i}.Visible = 'off';
            end

        end 
        
        if app.Rasters{app.Raster_Source}.UserData.x_lock(i) %if the user did not specify x axis limit inputs
            xlim( tmp_t{i}, [min(x_axis_begin) max(cell2mat(event_time_raw))+1] );%event_time(end)]);
        else
            if app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_lower_lim >= app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_upper_lim
                xlim( tmp_t{i}, [min(x_axis_begin) max(cell2mat(event_time_raw))+1] );%event_time(end)]);
            else
                xlim(tmp_t{i}, [app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_lower_lim app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_upper_lim] );%event_time(end)]);
            end
        end
        
        if ~isempty(Title) 
            title(tmp_t{i},Title{i},'FontSize',8); %adds title
        end

        if app.Rasters{app.Raster_Source}.UserData.Image_behavioral.UserData

            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.event_plot{i})
                
                app.Rasters{app.Raster_Source}.UserData.txt{i}.Text = [num2str(round(mean(adj_eventtime))) char(177) num2str(round(std(adj_eventtime)/sqrt(length(adj_eventtime))))];

            end

        else

            app.Rasters{app.Raster_Source}.UserData.txt.Text = "Rxn time";

        end
      

        
        
    end %for loop for raster grids
    
    
    if app.Rasters{app.Raster_Source}.UserData.Lock.UserData && ~all(cellfun(@(x) isempty(x), outertimer.UserData.Rasters{app.Raster_Source}.histo))
        for i = 1:length(outertimer.UserData.Rasters{app.Raster_Source}.histo)
            if ~isempty(outertimer.UserData.Rasters{app.Raster_Source}.histo{i})
                max_histo = [max_histo max(outertimer.UserData.Rasters{app.Raster_Source}.histo{i}.YData)];
            end
            
            
        end
        for i = 1:length(tmp_t)
            ylim(tmp_t{i},[0 round(max(max_histo))*2]);
                  
   
        end
        
    end
    for i = 1:length(tmp_t)
        if app.select_all_x
            if app.Rasters{app.Raster_Source}.UserData.x_lock(i)%if the user did not specify x axis limit inputs
                xlim( tmp_t{i}, [min(x_axis_begin) max(cell2mat(event_time_raw))+1] );%event_time(end)]);
            else
                if app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_lower_lim >= app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_upper_lim
                    xlim( tmp_t{i}, [min(x_axis_begin) max(cell2mat(event_time_raw))+1] );%event_time(end)]);
                else
                    xlim(tmp_t{i}, [app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_lower_lim app.Rasters{app.Raster_Source}.UserData.axis_data{i}.x_upper_lim] );%event_time(end)]);
                end
            end
        end

        if ~app.Rasters{app.Raster_Source}.UserData.Lock.UserData %if the lock button is not pushed(when lock is green)
            yyaxis(tmp_t{i},'left')

            if app.Rasters{app.Raster_Source}.UserData.axis_data{i}.yl_lower_lim >= app.Rasters{app.Raster_Source}.UserData.axis_data{i}.yl_upper_lim
                ylim( tmp_t{i},[0 round(max(conv_histo))*2]); %adjust y limit

            else
                ylim(tmp_t{i}, [app.Rasters{app.Raster_Source}.UserData.axis_data{i}.yl_lower_lim app.Rasters{app.Raster_Source}.UserData.axis_data{i}.yl_upper_lim]);
            end
        end
    end


    %for i=plot_ind
    %    delete(outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i});
    %    outertimer.UserData.Rasters{app.Raster_Source}.ref_plot{i} = xline(tmp_t{i},0,'--r');
    %end
    %
%     if app.Rasters{app.Raster_Source}.UserData.PlotRasterButton.UserData.newplot
%         offset = length(app.Rasters{app.Raster_Source}.Children)-app.Raster_index.reference;
%         RI = cell2struct(num2cell([cellfun(@(x) x+offset, struct2cell(app.Raster_index))]),...
%             {'event_label','ch_num','plot_button','row','col','lock','play','file_open_config',...
%             'file_save_config','file_save_data','file_open_data','kernel','neural','behavioral','stop','reference'});
%         
%         event.Source = app.Rasters{app.Raster_Source}.Children(RI.plot_button);
%         app.PlotRasterButtonPushed(event);
%         app.Rasters{event.Source.Parent.UserData.Sourcenum}.UserData.PlotRasterButton.UserData.newplot = 0;
%     end
    
    
    
    
end
outertimer.UserData.plotting =0;
