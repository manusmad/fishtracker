function analysis2
%global vm trig_points isi_ind isi sptr average x_axis waveform spikes a isis k jj 
%global sptr1 sptr2 ints extra_int phist spikes sptr cycle_meanvec all_sam_starts
global f
format compact
dir='0';
sptr_flag=0;
corr_flag=0;
newpp_flag=0;
vm_flag=0;
mask=gausswin(11,2.5);
mask=mask./sum(mask);
%mask=[1/3 1/3 1/3]
dt=.5
    nfft = 2048;
    window = bartlett(nfft);
    noverlap = 1024;
    dflag = 'none';
%main menue
stop=0;
while stop~=1
    sprintf('                   enter 1 for interval histogram')
    sprintf('                   enter 2 for spike autocor and psd')
    sprintf('                   enter 3 for EOD AM autocor and psd')
    sprintf('                   enter 4 for stimulus-spike train coherence')
    sprintf('                   enter 5 for spike triggered average')
    sprintf('                   enter 6 for phase histogram and analysis of subsets')
    sprintf('                   enter 7 for eod phase')
    sprintf('                   enter 8 for sp cross corr')
    sprintf('                   enter 9 chirp analysis')
    sprintf('                   enter 10 single x-y analysis')
    sprintf('                   enter 11 for tuning curve')
    sprintf('                   enter 12 to close all figures')
    sprintf('                   enter 0 to end')
    
    selectflag=input('enter choice');
    switch selectflag
%**************************************************************************

        case 1
            %interval histogram
            new_flag=input('1 to get new file, 0 to use existing sptr')
            if new_flag==1
                [fid, dir, fileid]=get_new_file(dir);
                sptr=get_spiketrain(fid);
                sptr=sptr.*1000;
            end
            %use selected region of spike train (1 msec resolution)
            start_time=input('enter start time in sec.');
            end_time=input('enter end time in sec.');
            bst_index=input('enter burst interval msec>>>')
            start_time=start_time*1000;
            end_time=end_time*1000;
            short_ind=find(sptr>start_time & sptr<=end_time);
            newsptr=sptr(short_ind);
            %isi's in msec
            isi=diff(newsptr);
            k=max(size(isi));
            %get % bursts
            bsts=find(isi<=bst_index);
            bsts=(max(size(bsts))/k)*100;
            edges=linspace(0,200,200);
            values=histc(isi,edges); 
            spont=1000/mean(isi);
            sspont=num2str(spont);
            id1=strcat('isih--',fileid)
            id2=strcat(sspont,'  sp/s')
            id0=strcat(num2str(k),' sp',num2str(bsts),'% bsts');
            figure
            
            set(gcf,'position',[1286         325         300         251]);
            BAR(edges,values,0.8);
            text (50, max(values)*.8,id1);
            text (50,max(values)*.6,id2);
            text (50,max(values)*.7,id0);
            sptr_flag=1;
%**********************************************************************
        case 2
            %autocorrelation and psd
            new_flag=input('1 to get new file, 0 to use existing sptr')
            if new_flag==1
                    [fid, dir, fileid]=get_new_file(dir);
                    sptr=get_spiketrain(fid);
                    sptr=sptr.*1000;
                    sptr_flag=1;
            end
            
            lastsptime=sptr(length(sptr));
            sptimes=round(sptr./dt);
            %check for initial spike at 0 time
            if sptimes(1)==0; sptimes(1)=1; end;
            trlength=round(lastsptime/dt)
            newsptr=zeros(trlength,1);
            newsptr(sptimes)=1;
            start_time=input('enter start time in sec.');
            end_time=input('enter end time in sec.');
            start_time=start_time*2000;
            end_time=end_time*2000;
            newsptr=newsptr(start_time:end_time);
            %do auto corr
            corr=xcorr(newsptr-mean(newsptr),100,'coeff');
            figure
            set(gcf,'position',[2226         327         332         251]);
            plot(corr(102:201));
            id1=strcat('acorr--',fileid)
            text (40, max(corr(102:201))*.8,id1)
            %do psd
            [Pxx,f2]=psd(newsptr-mean(newsptr),nfft,1000/dt,window,noverlap,dflag);
            mask=gausswin(11,2.5);
            mask=mask./sum(mask);
            Pxx=conv(Pxx,mask);
            Pxx=Pxx(10:length(Pxx)-10);
            figure
            set(gcf,'position',[1594         325         336         275]);
            %normalize psd by sampling rate
            plot(f2(3:100),Pxx(3:100).*2000)
            id1=strcat('psd--',fileid)
            text (40, max(Pxx(3:100))*.8,id1)
            corr_flag=1;
%**************************************************************************
        case 3
            %stim autocor and psd
            new_flag=input('1 to get new file, 0 to use existing file')
            if new_flag==1
               [fid, dir, fileid]=get_new_file(dir);
               sptr_flag=0;
               corr_flag=0;
               newpp_flag=0;
               vm_flag=0;
           end
                if newpp_flag==0
                newpp1=get_eod_am(fid);
                start_time=input('enter start time in sec.');
                end_time=input('enter end time in sec.');
                start_time=start_time*2000;
                end_time=end_time*2000;
                newpp1=newpp1(start_time:end_time);
                newpp1=newpp1-mean(newpp1);
                newpp_flag=1;
            end
            %do auto corr
            corr=xcorr(newpp1-mean(newpp1),100,'coeff');
            figure
            set(gcf,'position',[2226         327         332         251]);
            plot(corr(102:201));
            id1=strcat('s acor',fileid)
            text (40, max(corr(102:201))*.8,id1)
            %do psd
            [Pxx,f2]=psd(newpp1,nfft,1000/dt,window,noverlap,dflag);
            %mask=gausswin(11,2.5);
            %mask=mask./sum(mask);
            %Pxx=conv(Pxx,mask);
            %Pxx=Pxx(10:length(Pxx)-10);
            figure
            set(gcf,'position',[1594         325         336         275]);
            plot(f2(3:100),Pxx(3:100))
            id1=strcat('s psd',fileid)
            text (40, max(Pxx(3:100))*.8,id1)
 %******************************************************************************           
        case 4
            %stim-spike coherence
            new_flag=input('1 to get new file, 0 to use existing file')
            if new_flag==1
                [fid, dir, fileid]=get_new_file(dir);
                sptr_flag=0;
                corr_flag=0;
                newpp_flag=0;
                vm_flag=0;
            end
                %if newpp_flag==0
                newpp1=get_eod_am(fid);
                start_time=input('enter start time in sec.');
                end_time=input('enter end time in sec.');
                start_time=start_time*2000;
                end_time=end_time*2000;
                newpp1=newpp1(start_time:end_time);
                newpp1=newpp1-mean(newpp1);
                newpp_flag=1;
                %end
            if sptr_flag==0
                    sptr=get_spiketrain(fid);
                    sptr=sptr.*1000;
                    sptr_flag=1;
            end
            if corr_flag==0
                lastsptime=sptr(length(sptr));
                sptimes=round(sptr./dt);
                trlength=round(lastsptime/dt)
                newsptr=zeros(trlength,1);
                newsptr(sptimes)=1;
                newsptr=newsptr(start_time:end_time);
                sp_freq=sum(newsptr)/((end_time-start_time)/2000)
                %remove mean spike rate
                newsptr=newsptr-mean(newsptr);
            end
           [cxy,f]=cohere(newsptr,newpp1,nfft,2000,window,noverlap,dflag);
           %mask=gausswin(11,2.5);
           %mask=mask./sum(mask);
           %cxy=conv(cxy,mask);
           %cxy=cxy(10:length(cxy)-10);
           %calculate mutual information
           maxf=input('enter maximum relevant frequency')
           df=f(2)-f(1)
           maxf=fix(maxf/df)
           mi=-(df*log2(1/(1-cxy(1)))+df*log2(1/(1-cxy(maxf)))+df*sum(log2(1/(1-cxy(2:maxf-1)))))
           figure 
           set(gcf,'position',[1938         327         332         251]);
           plot(f(1:130),cxy(1:130));
           id1=strcat('cohere',fileid)
            text (40, max(cxy(3:100))*.97,id1)
            text(75,max(cxy(3:100))*.5,strcat(num2str(sp_freq),'sp/s'))
  %*******************************************************************************         
       case 5
           %spike triggered average of Vm or simulus 
           new_flag=input('1 to get new file, 0 to use existing file')
            if new_flag==1
                [fid, dir, fileid]=get_new_file(dir);
                sptr_flag=0;
                corr_flag=0;
                newpp_flag=0;
                vm_flag=0;
                eod_flag=0;
            end
            if sptr_flag==0
                 sptr=get_spiketrain(fid);
                 sptr=sptr.*1000;
                 sptr_flag=1;
            end
            if corr_flag==0
                lastsptime=sptr(length(sptr));
                sptimes=round(sptr./dt);
            end
           average_flag=input('1 for Vm average 2 for eod am average')
           if average_flag==1
               %send spktr to get_vm in msec and adjust according to Vm
               %sampling rate.  Returning Vm is filtered and resampled at
               %2khz
               if vm_flag==0
                   waveform=get_vm(fid,sptr);
                   vm_flag=1;
               end
           else
               if eod_flag==0
                   waveform=get_eod_am(fid);
                   eod_flag=1;
               end
           end
               start_time=input('enter start time in sec.');
               end_time=input('enter end time in sec.');
               start_time=start_time*1000;
               end_time=end_time*1000;
               short_ind=find(sptr>start_time & sptr<=end_time);
               newsptr=sptr(short_ind);
               isi=diff(newsptr);
               edges=linspace(0,200,200);
               values=histc(isi,edges);   
               spont=1000/mean(isi);
               sspont=num2str(spont);
               figure
               set(gcf,'position',[1286         325         300         251]);
               BAR(edges,values,0.8);
               id1=strcat('isih--',fileid)
               id2=strcat(sspont,'  sp/s')
               text (50, max(values)*.8,id1)
               text (50,max(values)*.6,id2)
               % loop here for multiple runs on same data
               loopflag=1;
               while loopflag==1
               %what spikes should be used for the average?
               isi_low=input('enter the smallest isi interval for averaging, 0 for all')
               isi_high=0;
               if isi_low~=0
                   isi_high=input('enter largest isi interval for averaging')
                   %isi's still in msec
                   isi_ind=find(isi>isi_low & isi<=isi_high);
                   isi_ind=isi_ind+1;
                   %isi_ind is the time of the second spike of the interval
                   trig_points=round(newsptr(isi_ind));
                   %Convert these indices to position in .5 msec units
                   trig_points=trig_points./dt;
                   
                   %figure (10)
                   %plot(trig_points.*5, waveform(trig_points),'.g')
               else
                   trig_points=round(newsptr./dt);
               end
               %make VM average over selected epoch
               avg_length=input('enter length of the average msec')
               avg_length=avg_length/dt;
               half_avg=round(avg_length/2);
               average=zeros(half_avg*2+1,1);
               x_axis=(0:.5:avg_length*dt)';
               for j=2:length(trig_points)-2
                   average=average+waveform(trig_points(j)-half_avg:trig_points(j)+half_avg);
               end
               average=average./length(trig_points);
               figure
               set(gcf,'position',[1286         325         300         251]);
               plot(x_axis,average);hold on
               plot([half_avg*dt+1,half_avg*dt+1],[min(average),max(average)],'r')
               id1=strcat('sp tr av',fileid)
               text (20, ((max(average)-min(average))*.9)+min(average),id1)
               id2=strcat(num2str(isi_low), 'to',num2str(isi_high),'ms')
               text(30,min(average),id2)
               loopflag=input('enter 1 to reanalyse, 0 to continue')
           end
 %***************************************************************************   
       case 6
           clear trig_points
           loopflag=0;
           
           new_flag=input('1 to get new file, 2 to read text file, 0 to use existing file')
           if new_flag==2
               [fid, dir, fileid]=get_new_file(dir);
               temp_data=fscanf(fid,'%g',[2 inf]);
               temp_data=temp_data';
               size(temp_data)
               msec_flg=input('enter 1 if spike times in msec, 0 if sec')
               if msec_flg==1
                   sptr=temp_data(:,1);
               else
                   sptr=temp_data(:,1).*1000;
               end
               ints=temp_data(:,2);
               clear temp_data
           else
                if new_flag==1
                    [fid, dir, fileid]=get_new_file(dir);
                    sptr_flag=0;
                    corr_flag=0;
                    newpp_flag=0;
                    vm_flag=0;
                    eodx_flag=0;
                end
                if sptr_flag==0
                    sptr=get_spiketrain(fid);
                    sptr=sptr.*1000;
                    sptr_flag=1;
                end
                
                %get cycle syncs
            sync_chan=input('enter stimulus sync channel')
            ints=songetchannel(fid,sync_chan);
            
            end
            binnum1=60;
            spikes=sptr./1000;
            datalen=fix(length(ints))
            length_flag=input('enter 0 to use all data, or number of cycles')
            if length_flag~=0
                datalen=length_flag
            end
    %make vector of start times
    %and add time shift?
            period=mean(diff(ints(1:100)))
            shift=input('enter sync shift in ms, + is earlier, 2, half cycle, 0 no shift')
            if shift>2; ints=ints-shift/1000; end
            if shift==2; ints=ints+(period/2); end
            startrast=ints;
            
           %get break in intervals
            brkstart=find(diff(ints)==max(diff(ints)));
            brkstop=brkstart+1
            %get trace length or mean stim cycle interval
            stimint=mean(diff(startrast(1:100)))
            maxspike=length(spikes);
    %make raster 
    %make list of xr and yr coordinates in msec versus replicates
    %build raster lines
        xr=0;
        yr=0;
        sp_per_cyc=0;
    for j=1:datalen-1
            xind=find((spikes>=startrast(j))&(spikes<startrast(j+1)));
            %subtract tracestart and retrieve actual times
            xtemp=spikes(xind)-startrast(j);
            if(startrast(j+1)-startrast(j)<stimint*2)
                sp_per_cyc(j)=length(xtemp);
            else
                sp_per_cyc(j)=0;
            end
            ytemp=zeros(length(xtemp),1);
            ytemp(:)=j;
              %if j>=brkstart
              % ytemp(:)=j+100;
              %end
             xr=[xr;xtemp];
             yr=[yr;ytemp];
   end
        xr=xr(2:length(xr));
        yr=yr(2:length(yr));
        %make raster plot
        figure
        set(gcf,'position',[1287         413         364         524])
        axis ij
        hold on
        axis ([0 stimint 0 datalen])
%change to upstroke-downstroke
%for j=1:length(xr)
%    plot([xr(j),xr(j)],[yr(j)-3,yr(j)+3],'k')
%end
        plot(xr,yr,'k.')
        hold off
        %plot spike count per cycle
        figure
        set(gcf,'position',[1659         477         891         469])
        plot(sp_per_cyc)
        %filtflg=input('enter 1 to filter, 0 not to')
   %if filtflg==1
         %generate filter
         %cutoff=input('enter cutoff freq. suggest .1---');
        %make filter
        %get nyquist
        nyquistf=(1/period)/2
        %cutoff=cutoff/nyquistf;
        cutoff=.1/nyquistf;
        [B,A]=butter(8,cutoff);
        %Filter  pp eod with butterworth,
        sp_per_cyc=filtfilt(B,A,sp_per_cyc);
        %sp_per_cyc=conv(mask,sp_per_cyc);
        %sp_per_cyc=sp_per_cyc(6:length(sp_per_cyc)-5);
        hold on
        set(gcf,'defaultlinelinewidth',2)
        plot(sp_per_cyc,'r')
        %end
%title(totalfile)    

   %loop through intervals getting spike times within each
   %put ties at end of histogram
   igo=1;
    while igo==1
        igo=input('1 to make a hist...');
    if igo~=1
       break
    end
   % set up vector of hist c edges
      brkstop
      binnum=360/binnum1
      edges=0:binnum:360;
      tempphase=0;
      phasehist=0;
      a=0;
      at=0;
      %get first and last raster line to use
      first_rep=input('first replicate...');
      last_rep=input('last replicate...');
      cycle_meanvec=0;
      tempradian=0;
      stepsize=input('enter number of cycles per mean vec calculation...');
      jk=stepsize;
      calc_count=0;
      time_count=0;
   for j=first_rep:last_rep
        i=find(spikes>ints(j) & spikes<=ints(j+1));
        tempphase=(spikes(i)-ints(j))./(ints(j+1)-ints(j));
        i=0;
        if jk>1
            at=[at;tempphase];
            jk=jk-1;
            time_count=time_count+(ints(j+1)-ints(j));
        else
            calc_count=calc_count+1;
            at=at(2:length(at)).*2.*pi;
            cyc_freq=length(at)/time_count;
            xpc=mean(cos(at));
            ypc=mean(sin(at));
            %put results into two dim arrray
            cycle_meanvec(calc_count,1)=j;
            cycle_meanvec(calc_count,2)=(xpc^2+ypc^2)^.5;
            cycle_meanvec(calc_count,3)=cyc_freq;
            %reset stepsize
            jk=stepsize;
            at=0;
            time_count=0;
        end
     tempphase=tempphase.*360;
     %concat the phase data
      a=[a;tempphase];
  end
  
    buff_sel=input('1 to save in buffer 1, 2 for b-2, 0 no save')
    if buff_sel==1
        mvec1(:,1)=cycle_meanvec(:,2);
        sp_f_1(:,1)=cycle_meanvec(:,3);
    end
    if buff_sel==2
        mvec2(:,1)=cycle_meanvec(:,2);
        sp_f_2(:,1)=cycle_meanvec(:,3);
        rms_dev_mvec=sqrt(mean((mvec1-mvec2).^2))
        rms_dev_spf=sqrt(mean((sp_f_1-sp_f_2).^2))
    end
    
  %plot cycle_mean vec
    %filter the plots
    filtflg=input('1 to filter plot 0 not to')
    if filtflg==1
        nyquistf=(1/(period*stepsize))/2
        cutoff=input('enter cutoff freq...');
        cutoff=cutoff/nyquistf
        [B,A]=butter(8,cutoff);
        cycle_meanvec(:,2)=filtfilt(B,A,cycle_meanvec(:,2));
        cycle_meanvec(:,3)=filtfilt(B,A,cycle_meanvec(:,3));
    end
     figure
     set(gcf,'defaultlinelinewidth',2)
     set(gcf,'position',[1659         413         892         524])
      plot(cycle_meanvec(:,1),cycle_meanvec(:,2))
      figure
     set(gcf,'defaultlinelinewidth',2)
     set(gcf,'position',[1659         413         892         524])
      plot(cycle_meanvec(:,1),cycle_meanvec(:,3))
      %get rid of first 0 in a
      a=a(2:length(a));
      %create the histogram
      phasehist=histc(a,edges');
      spcnt=sum(phasehist)
      %convert to sp/s
      btime=(stimint/binnum1)*(last_rep-first_rep+1)
      phasehist=phasehist./btime;
      sp_freq=mean(phasehist)
      %convert to prob density
      %phasehist=phasehist./sum(phasehist);
      %get rid of last 0 bin
      %phasehist=phasehist(1:length(phasehist)-1)
      figure
      set(gcf,'position',[1659         413         892         524])
      title(fileid) 
      pedges=edges+(binnum/2);
      bar(pedges',phasehist,1)
      barpatch=bar(pedges',phasehist,1);
      set(barpatch,'facecolor',[0 0 0]);
      set(gca,'TickDir','out')
      set(gca, 'Xlim', [0 360])
      set(gca,'XTick', [0:20:360])
      set(gca, 'Ylim', [0 max(phasehist)])
      %set(gca,'YTick', [0 .125 .25])
      set (gca, 'Box', 'off')
      set(gca, 'TickLength', [.025, .01])
      %phasemodflag=input('enter 1 to use phasehistmod, 0 not to')
      %if phasemodflag==1; phasehistmod; end
      % convert array a to radians
      aradians=(a./360).*2.*pi;
      %get mean vector and its direction
        xp=mean(cos(aradians))
        yp=mean(sin(aradians))
      %save for mean vec diff?
    vec_diff=input('enter 1 to put in buff1, 2 for buff2, 0 for no save')
        if vec_diff~=0
            if vec_diff==1
                xp1=xp;
                yp1=yp;
            end
        if vec_diff==2
           xp2=xp;
           yp2=yp;
           mean_vec_diff=((xp1-xp2)^2+(yp1-yp2)^2)^.5
        end
   end
   %get mean vector
   meanvec=(xp^2+yp^2)^.5
   tempout(1,1)=meanvec;
   %get direction of mean vector
   direct=complex(xp,yp);
   direct=angle(direct);
   direct=direct/(2*pi)*360;
   if direct<0
      direct=360+direct
   else
      direct=direct
   end
   tempout(1,2)=direct
   zstat=length(aradians)*(meanvec^2)
   %get average spike count
  % spcnt=sum(phasehist)/(last_rep-first_rep)+1
   
   % loop here for multiple runs on same data
   loopflag=input('enter 1 for detailed analysis, 0 for new file')
     %loopflag=1
     while loopflag==1
       %get limits of phase hist to use
       low_phase=input('enter low phase to use')
       high_phase=input('enter high phase to use')
       bst_index=input('enter burst interval msec>>>')
       %get indices of desired phase range
       phase_ind=find(a>low_phase & a<=high_phase);
       trig_points=round(spikes(phase_ind).*2e3);
       %these should map onto spikes
       isi_flag=input('enter 1 for isih of subset')
       if isi_flag==1
           %create list of isi's based on spikes(phase_ind)
           k=max(size(phase_ind));
           isis=zeros(k-1,1);
           for jj=2:k
               isis(jj)=spikes(phase_ind(jj))-spikes(phase_ind(jj)-1);
           end
           %turn into ms
           isis=isis.*1000;
           %get % bursts
           bsts=find(isis<=bst_index);
           bsts=max(size(bsts))/max(size(isis));
           edges=linspace(0,200,200);
           values=histc(isis,edges); 
           spont=1000/mean(isis);
           sspont=num2str(spont);
           id0=strcat(num2str(k),' sp',num2str(bsts),'% bsts');
           id1=strcat('isih--',fileid);
           id2=strcat(sspont,'  sp/s');
           id3=strcat(num2str(low_phase), 'to',num2str(high_phase),'ms');
           figure
           
           set(gcf,'position',[1286         325         300         251]);
           BAR(edges,values,0.8);
           text (50, max(values)*.9,id1)
           text (50,max(values)*.8,id2)
           text (50,max(values)*.7,id3)
           text (50,max(values)*.6,id0)
       end
       
       vm_avg_flag=input('enter 1 for vm  sp trig average, 0 no')
        if vm_avg_flag==1
       %get vm record/ comes back with 2 khz sampling rate
               if vm_flag==0
                   waveform=get_vm(fid,sptr);
                   vm_flag=1;
               end
      
      %make VM average over selected epoch
               avg_length=input('enter length of the average msec')
               avg_length=avg_length/dt;
               half_avg=round(avg_length/2);
               average=zeros(half_avg*2+1,1);
               x_axis=(0:.5:avg_length*dt)';
               for j=2:length(trig_points)-2
                   average=average+waveform(trig_points(j)-half_avg:trig_points(j)+half_avg);
               end
               average=average./length(trig_points);
               figure
               set(gcf,'position',[1286         325         300         251]);
               plot(x_axis,average);hold on
               plot([half_avg*dt+1,half_avg*dt+1],[min(average),max(average)],'r')
               id1=strcat('sp tr av',fileid)
               text (20, ((max(average)-min(average))*.9)+min(average),id1)
               id2=strcat(num2str(low_phase), 'to',num2str(high_phase),'ms')
               text(30,min(average),id2)
               
     end
     
     %make eod phase over subset
     phase_flag=input('enter 1 for subset eod phase, 0 for no')
     if phase_flag==1
         if eodx_flag==0
            zcross=input('enter eod trigger channel')
            Info=SONChannelInfo(fid,zcross);
            %eodxaxis=songetchannel(fid,zcross);
            eodxaxis_temp=songetchannel(fid,zcross);
            if Info.kind==5
            eodxaxis=eodxaxis_temp.timings;
            else
            syncs=eodxaxis_temp;
            end
            clear eodxaxis_temp
            eodx_flag=1
        end
      phase_points=trig_points./2e3;
      zl=length(phase_points)
      for j=2:zl-2
          p2ind=find(syncs>=phase_points(j));
          p2=syncs(p2ind(1));
          p1=syncs(p2ind(1)-1);
          phase(j)=(phase_points(j)-p1)/(p2-p1);
      end
            %convert to degrees
            %phase=eodph(spikes,syncs);
        phased=phase.*360;
	        %convert to radians
        phase=phase.*(2*pi);
            %generate bins
        x=0:5:360;
        phist=histc(phased,x);
        figure
        set(gcf,'position',[1286         325         300         251]);
        bar(x+2.5,phist,1)
        barpatch=bar(x+2.5,phist,1);
    
        set(barpatch,'facecolor',[0 0 0]);
        set(barpatch,'edgecolor',[0 0 0]);
        set(barpatch,'linewidth',[.1]);
        set(gca,'TickDir','out')
            %get average sines and cosines
        xp=mean(cos(phase))
        yp=mean(sin(phase))
            %get mean vector
        meanvec=(xp^2+yp^2)^.5
            %get direction of mean vector
        direct=complex(xp,yp);
        direct=angle(direct);
        direct=direct/(2*pi)*360;
        if direct<0
            direct=360+direct
        else
            direct=direct
        end
        zstat=zl*(meanvec^2)
        id1=strcat('eod phase',fileid);
        id2=strcat('mv=',num2str(meanvec),'zstat',num2str(zstat));
        id3=strcat(num2str(low_phase), 'to',num2str(high_phase),'ms')
        text(30,max(phist)*.9,id1);
        text(30,max(phist)*.8,id2);
        text(30,max(phist)*.7,id3);
     end 
       loopflag=input('enter 1 to reanalyse, 0 to continue')
    end
    end
 %*************************************************************************
case 7
    %eod phase from whole file
    new_flag=input('1 to get new file, 0 to use crosscorr files')
     if new_flag==1
                [fid, dir, fileid]=get_new_file(dir);
                sptr_flag=0;
                corr_flag=0;
                newpp_flag=0;
                vm_flag=0;
                eodx_flag=0;
                spikes=get_spiketrain(fid);
                zcross=input('enter eod trigger channel')
               Info=SONChannelInfo(fid,zcross);
               %eodxaxis=songetchannel(fid,zcross);
                eodxaxis_temp=songetchannel(fid,zcross);
               if Info.kind==5
                  eodxaxis=eodxaxis_temp.timings;
              else
                  syncs=eodxaxis_temp;
              end
               clear eodxaxis_temp
               eodx_flag=1;
               zl=length(spikes)
               half_cyc=mean(diff(syncs))/2
                jitflag=input('enter 1 to add jitter to spike trains, 0 not to')
               if jitflag==1
                   %R=random('unif',-half_cyc,half_cyc,zl,1);
                   R=random('unif',-.001,.001,zl,1);
                    spikes=spikes+R;
              end
     else
          spike_id=input('1 for sptr1 or 2 for sptr2 (trigger sptr)')
          if spike_id==1
              spikes=sptr1t;
              zl=length(spikes)
          else
              spikes=sptr2t;
              zl=length(spikes)
          end
      end
tic
    for j=2:zl-1
      p2ind=find(syncs>=spikes(j));
      p2=syncs(p2ind(1));
      p1=syncs(p2ind(1)-1);
      phase(j)=(spikes(j)-p1)/(p2-p1);
   end
toc
      %convert to degrees
      %phase=eodph(spikes,syncs);
   phased=phase.*360;
	%convert to radians
   phase=phase.*(2*pi);
   %generate bins
   x=0:5:360;
   phist=histc(phased,x);
   figure
   set(gcf,'position',[1286         325         300         251]);
   bar(x+2.5,phist,1)
   barpatch=bar(x+2.5,phist,1);
    
    set(barpatch,'facecolor',[0 0 0]);
    set(barpatch,'edgecolor',[0 0 0]);
    set(barpatch,'linewidth',[.1]);
    set(gca,'TickDir','out')
   %get average sines and cosines
   xp=mean(cos(phase))
   yp=mean(sin(phase))
   %get mean vector
   meanvec=(xp^2+yp^2)^.5
   %get direction of mean vector
   direct=complex(xp,yp);
   direct=angle(direct);
   direct=direct/(2*pi)*360;
   if direct<0
      direct=360+direct
   else
      direct=direct
   end
    zstat=zl*(meanvec^2)
    id1=strcat('eod phase',fileid);
    id2=strcat('mvec=',num2str(meanvec),'zstat',num2str(zstat));
    text(30,max(phist)*.9,id1);
    text(30,max(phist)*.8,id2);
%*****************************************************************************   
        case 8
            %spike train cross corr
            %
            %
            %get first spike train
            [fid, dir, fileid]=get_new_file(dir);
            display ('2nd spike train is "trigger"')           
            sptr1t=get_spiketrain(fid);
            %get 2nd spike train
            sptr2t=get_spiketrain(fid);
            %add jitter?
            
                zcross=input('enter eod trigger channel')
                Info=SONChannelInfo(fid,zcross);
                %eodxaxis=songetchannel(fid,zcross);
                eodxaxis_temp=songetchannel(fid,zcross);
                if Info.kind==5
                eodxaxis=eodxaxis_temp.timings;
                else
                syncs=eodxaxis_temp;
                end
                clear eodxaxis_temp
                eodx_flag=1;
                jitflag=input('enter 1 to add jitter to spike trains, 0 not to')
            if jitflag==1
                half_cyc=mean(diff(syncs))/2
                R=random('unif',-half_cyc,half_cyc,length(sptr1t),1);
                sptr1t=sptr1t+R;
                R=random('unif',-half_cyc,half_cyc,length(sptr2t),1);
                sptr2t=sptr2t+R;
            end
            %cross corr the spike trains and the eod
            
            
            %get synch pulses
            %sync_chan=input('enter stimulus sync channel');
            display('enter stimulus sync channel')
            %intf=songetchannel(fid,sync_chan)
            intf=get_spiketrain(fid);
            %subdivide spiketrains ?
            sub_flag=input('enter 1 to subdivide spike train 0 not to')
            if sub_flag==1
                pulse_flag=input('enter 1 to select odd pulses, 2 for even,');
                ints=intf(pulse_flag:2:length(intf));
                if pulse_flag==2; extra_int=max(ints)+mean(diff(intf));end
                last_int=max(ints)
                %make new spiketrain 1
                sptr1=[];
                sptr2=[];
                for j=pulse_flag:2:length(intf)
                    if pulse_flag==2 & j==length(intf);
                        id1=find(sptr1t>intf(j) & sptr1t<=extra_int);
                        sptr1=[sptr1;sptr1t(id1)];
                        id2=find(sptr2t>intf(j) & sptr2t<=extra_int);
                        sptr2=[sptr2;sptr2t(id2)];
                    else
                    id1=find(sptr1t>intf(j) & sptr1t<=intf(j+1));
                    sptr1=[sptr1;sptr1t(id1)];
                    id2=find(sptr2t>intf(j) & sptr2t<=intf(j+1));
                    sptr2=[sptr2;sptr2t(id2)];
                    end
                end
                sptr1=sptr1.*1000;
                sptr2=sptr2.*1000;
            else
            ints=intf;    
            sptr1=sptr1t.*1000;   
            sptr2=sptr2t.*1000;
            end
            %all spikes or just burst spikes
            bst_flag=input('enter burst interval(ms)to use bursts or 0***');
            if bst_flag>0
                k=1;
                for j=2:length(sptr2)
                    if sptr2(j)-sptr2(j-1)<=bst_flag
                        tsptr2(k)=sptr2(j);
                        k=k+1
                    end
                end
                sptr2=tsptr2;
            end
                        
            %find longest sptrain
            lastsptime=max([sptr1(length(sptr1)), sptr2(length(sptr2))])
            sptimes1=round(sptr1./dt);
            sptimes2=round(sptr2./dt);
            trlength=round(lastsptime/dt)
            newsptr1=zeros(trlength,1);
            newsptr1(sptimes1)=1;
            newsptr2=zeros(trlength,1);
            newsptr2(sptimes2)=1;
            start_time=input('enter start time in sec.');
            end_time=input('enter end time in sec.');
            start_time=start_time*2000;
            end_time=end_time*2000;
            shift_flag=input('enter 1 to do shift predictor, 0 not to')
            if shift_flag==1
                ints=round(ints./5e-4);
                %find ints between start and end times
                valid_ints=find(ints>=start_time & ints<=end_time);
                num_cycles=size(valid_ints)
                ints=ints(valid_ints);
                start_time=ints(1)
                end_time=ints(length(ints))
                ints=ints-ints(1)+1;
            end
            
            newsptr1=newsptr1(start_time:end_time);
            newsptr2=newsptr2(start_time:end_time);
            
            %do xcorr
            % do not zero mean correct
            [corr, lags]=xcorr(newsptr1,newsptr2,200,'none');
            lags=lags./2000;
            %filter corr
            %corr=conv(mask,corr);
            %corr=corr(6:length(corr)-5);
            %corr=xcorr(newsptr1-mean(newsptr1),newsptr2-mean(newsptr2),200,'coef');
            %convert to probab dens
            corr=corr./sum(corr);
            figure
            set(gcf,'position',[2226         327         332         251]);
            plot(lags,corr(1:401));
            hold on
            plot([lags(201) lags(201)], [0, max(corr)],'r');
            id1=strcat('xcorr--',fileid);
            text (40, max(corr(102:201))*.8,id1)
            %do shift predictor?***********************
            
            if shift_flag==1
                
                shift_num=input('enter number of shifts to average');
                shift_temp=zeros(401,1);
               
                control_flag=input('enter shift # to subtract one shifted file, or 0')
                for j=1:shift_num
                    shift_size=j+1;
                %get time of shift_size, just the nth sync
                %this is the number of positions in the 2khz train
                    shift_point=ints(shift_size)
                %save portion of newsptr1>=shiftpoint
                    newsptr3=newsptr1(shift_point:length(newsptr1));
                %add on piece of newsptr1<shift_point
                    newsptr3=cat(1,newsptr3,newsptr1(1:shift_point-1));
                    size(newsptr1)
                    size(newsptr3)
                    [scorr, lags]=xcorr(newsptr3,newsptr2,200,'none');
                    shift_temp=shift_temp+scorr;
                    if control_flag~=0 & j==control_flag
                        scorr1=scorr./sum(scorr);
                    end
                        
                end
                scorr=shift_temp./shift_num;
                %scorr=conv(mask,scorr);
                %scorr=scorr(6:length(scorr)-5);
                lags=lags./2000;
                scorr=scorr./sum(scorr);
                figure
                set(gcf,'position',[2226         327         332         251]);
                plot(lags,scorr(1:401));
                hold on
                plot([lags(201) lags(201)], [0, max(corr)],'r');
                id1=strcat('shifted xcorr--',fileid);
                text (40, max(corr(102:201))*.8,id1)
                %plot differences in xcorrs
                xdiff=corr-scorr;
                figure
                hold on
                set(gcf,'position',[1286         379         612         559]);
                plot(lags,xdiff(1:401),'k');
                
                %filter the diff plot
                xdiff=conv(mask,xdiff);
                xdiff=xdiff(6:length(xdiff)-5);
                plot(lags,xdiff(1:401),'g','LineWidth',1);
              
                plot([lags(201) lags(201)], [0, max(xdiff)],'r');
                id1=strcat('difference',fileid);
                text (40, max(corr(102:201))*.8,id1)
                if control_flag~=0
                    %plot differences in xcorrs
                    xdiff=scorr1-scorr;
                    %figure
                    set(gcf,'position',[1286         379         612         559]);
                    %plot(lags,xdiff(1:401));
                    
                
                    %filter the diff plot
                    xdiff=conv(mask,xdiff);
                    xdiff=xdiff(6:length(xdiff)-5);
                    plot(lags,xdiff(1:401),'b','LineWidth',1);
                    hold on
                    plot([lags(201) lags(201)], [0, max(xdiff)],'r');
                    id1=strcat('difference',fileid);
                    text (40, max(corr(102:201))*.8,id1)
                end
            end
                
 %*************************************************************************
        case 9
            %find chirps 1st do interval versus order plot
                [fid, dir, fileid]=get_new_file(dir);
                zcross=input('enter eod trigger channel')
                Info=SONChannelInfo(fid,zcross);
                %eodxaxis=songetchannel(fid,zcross);
                eodxaxis_temp=songetchannel(fid,zcross);
                if Info.kind==5
                eodxaxis=eodxaxis_temp.timings;
                else
                syncs=eodxaxis_temp;
                end
                clear eodxaxis_temp
                eod_freq=1./diff(syncs);
                figure
                set (gcf,'position',[6         501        1268         439]);
                plot(syncs(2:length(syncs)),eod_freq,'.r')
                % input chirp threshold frrequency
                thresh=input('enter chirp thresh Hz');
                hold on
                plot([syncs(2), syncs(length(syncs))],[thresh thresh]);
                chirps=find(eod_freq>thresh);
                diff_chirp=diff(chirps);
                st_chirp=find(diff_chirp>10);
               for j=1:length(st_chirp)
                   st_chirp_ind(j+1)=sum(diff_chirp(1:st_chirp(j)));
               end
               st_chirp_ind=st_chirp_ind+chirps(1)+1;
                length(eod_freq);
                num_chirps=length(st_chirp_ind)
                plot(syncs(st_chirp_ind),eod_freq(st_chirp_ind-1),'.g')
                %make histogram of spike times around chirp time
                sptr=get_spiketrain(fid);
                chirp_sp_hist=zeros(201,1);
                for j=1:length(st_chirp_ind)
                    hist_center=syncs(st_chirp_ind(j));
                    sp_ind=find(sptr>=hist_center-.1 & sptr<=hist_center+.1);
                    %convert to ms
                    %this is the index into the hist
                    hist_index=round((sptr(sp_ind)-hist_center).*1000)+101
                    chirp_sp_hist(hist_index)=chirp_sp_hist(hist_index)+1;
                end
                
                figure
                plot(chirp_sp_hist)
    
 %*************************************************************************
 
       case 10
            %single xy analysis
            %get start markers (ch 2)
            new_flag=input('1 to get new file, 0 to use existing sptr')
        if new_flag==1
            [fid, dir, fileid]=get_new_file(dir);
            sync_chan=input('enter movement start pulses (ch2)---');
            syncs=songetchannel(fid,sync_chan);
            %get spikes
            sptr=get_spiketrain(fid);
            %make list of hwd start times
            headst=syncs(1:2:length(syncs));
            tailst=syncs(2:2:length(syncs));
            %remove delays (.38 s in both cases)
            headst=headst+.38;
            tailst=tailst+.38;
        end
        cycle_time=mean(diff(headst))
        st_time=input('enter start time of xylo inj')
        st_time=st_time/cycle_time
            number_hdwd=length(headst)
            number_twd=length(tailst)
            hist_st=input('enter first replicate to process---');
            hist_stop=input('enter last replicat to process---');
            bwidth=input('enter histogram binwidth ms');
            bwidth=bwidth/1000;
            %make x-axis
            sze=mean(diff(syncs));
            x_axis=[0:bwidth:sze];
            %loop through the selected cycles
            h_hist=0;
            t_hist=0;
            n=hist_stop-hist_st+1
            for j=hist_st:hist_stop
                h_hist=h_hist+histc(sptr,x_axis+headst(j));
                t_hist=t_hist+histc(sptr,x_axis+tailst(j));
            end
            %convert to sp./sec
            t_hist=t_hist./(n*bwidth);
            h_hist=h_hist./(n*bwidth);
            super_flag=input('enter 1 to superimpose plots, 0 for new fig')
            if super_flag==1
                figure (1)
                hold on
                colr=input('enter color code','s')
                plot(x_axis,h_hist,colr)
                hold off
                figure (2)
                hold on
                plot(x_axis,t_hist,colr)
                hold off
            else
                figure (1)
                set(gcf,'position',[1290         521         612         394]);
                plot(x_axis,h_hist)
                figure (2)
                set(gcf,'position',[1942         521         612         394]);
                plot(x_axis,t_hist)
            end
          width_flg=input('enter 1 to calc peak width, 0 no');
          if width_flg==1
              %get control period from hwd
              cont_1=input('enter start of control period');
              cont_2=input('enter end of control period');
              cont_1=round(cont_1/bwidth)
              cont_2=round(cont_2/bwidth)
              cont_freq=mean(h_hist(cont_1:cont_2));
              max_h=max(h_hist)
              max_t=max(t_hist)
              %get width at 1/2 max-control
              thresh_h=((max_h-cont_freq)/2)+cont_freq
              thresh_t=((max_t-cont_freq)/2)+cont_freq
              %insure that only one peak is measured
              width_h=length(find(h_hist>=thresh_h))*bwidth
              width_t=length(find(t_hist>=thresh_t))*bwidth
          end
          
%************************************************************************** 
       case 11
            %automatic tuning curve
            %get spiketrains
            %generate bins
            %x=0:6:360;
            %figure
            %hold on
            [fid, dir, fileid]=get_new_file(dir);
                sptr=get_spiketrain(fid);
                %sptr=sptr.*1000;
            %get sam starts
            display ('get sam start channel')
            all_sam_starts=get_spiketrain(fid);
            %get epoch markers
            fstep_chan=input('freq. step channel #---')
            [fstepvalues,header]=songetchannel(fid,fstep_chan);
            %convert to float
            fstepvalues=sonadctodouble(fstepvalues,header);
            atod_int=header.sampleinterval   
            %get epoch starts
            fstep_starts=find(fstepvalues>=.5);
            fstep_starts=fstep_starts.*atod_int;
            mean_epoch_length=mean(diff(fstep_starts))
            number_of_steps=length(fstep_starts)
            %zero out output array
            tcurve=zeros(number_of_steps,4);
            %loop through number_of_steps
            for j=1:number_of_steps
                %get sam starts
                if j<number_of_steps
                    samstarts_ind=find(all_sam_starts>=fstep_starts(j)...
                         & all_sam_starts<=fstep_starts(j+1));
                else
                    samstarts_ind=find(all_sam_starts>=fstep_starts(j)...
                         & all_sam_starts<=fstep_starts(j)+mean_epoch_length);
                end
                %get am freq
                tcurve(j,1)=1/mean(diff(all_sam_starts(samstarts_ind)));
                tcurve(j,4)=length(samstarts_ind);
                %loop through samstarts
                samstarts=all_sam_starts(samstarts_ind);
                tempphase=0;
                at=0;
                sum_spikes=0;
                sp_ind=0;
                for k=1:length(samstarts)-1
                    %get spiktimes within each sam cycle
                    sp_ind=find(sptr>=samstarts(k) & sptr<samstarts(k+1));
                    %convert to fractional interval
                    tempphase=(sptr(sp_ind)-samstarts(k))./...
                        (samstarts(k+1)-samstarts(k));
                    %concat to at
                    at=[at;tempphase];
                    %running sum of spikes
                    sum_spikes=sum_spikes+length(sp_ind);
                end
                
                %calc mean vector
                %convert to rad
                at=at(2:length(at)).*2.*pi;
                xp=mean(cos(at));
                yp=mean(sin(at));
                %get mean vector
                tcurve(j,2)=(xp^2+yp^2)^.5;
                %get mean sp freq
                tcurve(j,3)=sum_spikes/mean_epoch_length;
                %plot phase hist
                %convert to degrees
                %at=(at./(2*pi)).*360;
                
                %phist=histc(at,x);
                %stairs(x',phist)
            end
            figure
            plot(tcurve(:,1),tcurve(:,2),'bo-')
            figure
            plot(tcurve(:,1),tcurve(:,3),'rs-')
            tcurve
%**************************************************************************
       case 12
            close all
%**************************************************************************
       case 0
            stop=1
            fclose(fid);
    end
    
    
end
    
    
    