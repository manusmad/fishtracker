function spiketimes=get_spiketrain(fid)

%read spike times
        spikechan=input('input time channel #, or zero---');
        if spikechan~=0
            %find out if original data or reanalyzed markers
            Info=SONChannelInfo(fid,spikechan);
            spiketimes_temp=songetchannel(fid,spikechan);
                if Info.kind==5
                    spiketimes=spiketimes_temp.timings;
                else
                    spiketimes=spiketimes_temp;
                end
            clear spiketimes_temp
        end
        %print length of spike train
        trainlength=max(spiketimes)