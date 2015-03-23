function newpp1=get_eod_am(fid)

  %get eod channel
    atodchan1=input('enter 1st eod waveform channel #, or zero---')
    if atodchan1~=0
        [atod,header]=songetchannel(fid,atodchan1);
        %convert to float
        atod1=sonadctodouble(atod,header);
        atod_int=header.sampleinterval
    end      
   
    zcross=input('enter eod trigger channel or zero---')
        if zcross~= 0
            Info=SONChannelInfo(fid,zcross);
            %eodxaxis=songetchannel(fid,zcross);
            eodxaxis_temp=songetchannel(fid,zcross);
            if Info.kind==5
            eodxaxis=eodxaxis_temp.timings;
            else
            eodxaxis=eodxaxis_temp;
            end
        clear eodxaxis_temp
        
        %extract p-p EOD am via mex file eodamp
        %
        dot=mean(diff(eodxaxis))
        samprate=1./dot
        %time this routine
        
                display ('working on atod1')
                tic;
                p_peod_1=eodamp(eodxaxis,atod1);
                toc
               
      %resample to 2 Khz, (newdt) from 0 to maxtime)
        maxtime=length(atod1)*atod_int;
        clear atod1
        %make neodxaxis in terms of newdt
        newdt=5e-4;
        neodxaxis=newdt:newdt:maxtime;
        neodxaxis=neodxaxis';
        %interpolate 
        eodxaxis=eodxaxis(1:length(eodxaxis)-1);
        newpp1=interp1(eodxaxis,p_peod_1,neodxaxis,'spline');
        filt_flag=input('enter 1 to filter, 0 not to***');
        clear p_peod_1
        if filt_flag~=0
       %generate filter
         cutofflow=input('enter desired low cutoff freq.---');
         cutoffhigh=input('enter desired high cutoff freq.---');
        %get cutoffs relative to nyquist
         cutofflow=cutofflow./1e3;
         cutoffhigh=cutoffhigh./1e3;
         
        %make filter
     if cutofflow==0
         [B,A]=butter(8,cutoffhigh);
     else
         [B,A]=butter(4,[cutofflow cutoffhigh]);
     end  
        %Filter  average
         newpp1=filtfilt(B,A,newpp1);
         %set(gcf,'DefaultLineLineWidth',2)
      
        figure (1)
        set(gcf,'position',[1286 689 1264 249])
        %plot(eodxaxis,p_peod,'r')
        %hold on
        plot(neodxaxis,newpp1,'k')
        %newpp=newpp-mean(newpp);
        %newpp=newpp';
    end
end