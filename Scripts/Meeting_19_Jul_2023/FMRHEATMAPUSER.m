close all
clear

prompt = 'Type the title:';
pre = input(prompt,'s') 

mkdir(pre)

save_vid_time=1;
vfiletype='Motion JPEG AVI'; 
fr=10;
giffy=1;
delay=0.2;
H_res=50;
split=0;

map='hot';
set(0,'defaultfigurecolor',[1 1 1]);
save_png=0;


comp_sep=0;

fmin=2;fmax=15;fres=1;
Xmin=-20;Xmax=50;Xres=10;
%Xmin=0;Xmax=700;Xres=40;
cmin=0;cmax=1;
set(0,'defaultfigurecolor',[1 1 1])



c_log=1;
combine=5;
backsweep=0;

region=[2,21,32,35,41,38];   %0-m  21-demag 33-TTL 36-TTR 39-TBR
regionname={'m','demag','TL','TR','BL','BR'};
if combine==1 %TRILAYER%
region=[2,21,32,35,41,38,44,47,53,50];   %0-m  21-demag 33-TTL 36-TTR 39-TBR
regionname={'m','demag','T-TL','T-TR','T-BL','T-BR','B-TL','B-TR','B-BL','B-BR'};
end
if combine==2 %ASI AND UNDERLAYER%
region=[2,32,35,29,41,38];
regionname={'m','TL','TR','UL','BL','BR',};
end

if combine==3 %TRILAYER ISLAND
region=[2,32,44];
regionname={'m','T','B',}; 
end
if combine==4 %SIMPLE ASI
region=[2,32,35,41,38];   %0-m  33-TTL 36-TTR 39-TBR
regionname={'m','TL','TR','BL','BR'};
end
if combine==5 %SIMPLE ASI
region=2;   %0-m  33-TTL 36-TTR 39-TBR
regionname={'m'};
end



table1 = importdata('table.txt');
tabledata=table1.data;
tablenames=table1.textdata;

Table=array2table(tabledata,'VariableNames',tablenames);

H=tabledata(:,16)./10;H_u=unique(H);H_l=length(H_u);
t=tabledata(:,1);t_u=t(1:length(t)/H_l);t_l=length(t_u);

Nx=tabledata(1,5); Ny=tabledata(1,6); Nz=tabledata(1,7); %pull cell number
cx=tabledata(1,8);cy=tabledata(1,9);cz=tabledata(1,10);  %pull cell size
LX=(cx:cx:cx*Nx)*1e9;
LY=(cy:cy:cy*Ny)*1e9;
LZ=(cz:cz:cz*Nz)*1e9;

FFTi=[];

for r=1:length(region)
suffix=regionname(r);
mregion=region(r)    ;

mx=tabledata(:,mregion);
my=tabledata(:,mregion+1);
mz=tabledata(:,mregion+2);

running=length(t)/t_l;
if isinteger(running)==0
rnd=round(running);
    if r==1
    H_l=H_l-1;
    end
mx=mx(1:H_l*t_l);
my=my(1:H_l*t_l);
mz=mz(1:H_l*t_l);
end

mx=reshape(mx,t_l,H_l);
my=reshape(my,t_l,H_l);
mz=reshape(mz,t_l,H_l);


mxDyn=mx-(mx(1,:));
myDyn=my-(my(1,:));
mzDyn=mz-(mz(1,:));

m = sqrt(mx.^2+my.^2+mz.^2);
m_dyn = m-m(1,:);

%%Time specifications for FFT to get frequency:
dt = mean(diff(t_u)).*1e9;
Fs = 1/dt; N = t_l;
dF = Fs/N; f = -Fs/2+dF:dF:Fs/2; 


FFTx = abs((fft(mxDyn)));
FFTy = abs((fft(myDyn)));
FFTz = abs((fft(mzDyn)));

f=f(floor(t_l/2+1):t_l);
FFTx=flipud(FFTx(floor(t_l/2+1):t_l,:));
FFTy=flipud(FFTy(floor(t_l/2+1):t_l,:));
FFTz=flipud(FFTz(floor(t_l/2+1):t_l,:));

FFT=sqrt(FFTx.^2+FFTy.^2+FFTz.^2);
% if combine==1
% if r>2
%     FFTi=cat(3,FFTi,FFT);
% end
% end
% if combine==2||3
%     FFTi=cat(3,FFTi,FFT);
% end

FFTi=cat(3,FFTi,FFT);


figure; set(gcf,'color','w');
imagesc(H,f,FFT)
set(gca,'YDir','normal')
colormap(map);colorbar;
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
caxis([cmin cmax]);
xlabel('\mu_{0}H (mT)');
ylabel('frequency (GHz)');
set(gca,'FontSize',14);
% title([pre,suffix],Interpreter="none")
title([pre],Interpreter="none")

nameunit = '.png';


name=[pre '/' pre '_' char(suffix) nameunit];
saveas(gcf,(name))

if comp_sep==1

figure('rend','painters','pos',[100 100 1200 300]); set(gcf,'color','w');
subplot(1,3,1)
imagesc(H,f,FFTx)
set(gca,'YDir','normal')
colormap(map);colorbar;
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
title('mx');

subplot(1,3,2)
imagesc(H,f,FFTy)
set(gca,'YDir','normal');
colormap(map);colorbar;
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
title('my');

subplot(1,3,3)
imagesc(H,f,FFTz);
set(gca,'YDir','normal')
colormap(map);colorbar;
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
title('mz')
sgtitle(suffix)



name=[pre '/' pre '_' char(suffix) nameunit];
saveas(gcf,(name))



end
end


%%
if combine==1

figure('rend','painters','pos',[100 100 800 1200])
FFTnorm=FFTi./max(max(max(FFTi)));
%FFTnorm=FFTi;%./mean(mean(mean(FFTi)))
for j=1:8
    i=j+2
subplot(4,2,j)
imagesc(H,f,FFTnorm(:,:,i))
set(gca,'YDir','normal')
colormap(map);caxis([0.0001 0.001]);
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');
ylabel('frequency (GHz)');
set(gca,'FontSize',10);
title([pre,regionname(i)],Interpreter="none")

%colorbar


end
hp4 = get(subplot(4,2,8),'Position');
colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(3)  0.02  hp4(2)+hp4(3)*0.5])

saveas(gcf,[pre '/' pre '_FMR_sep.png'])
%%


M=FFTi(:,:,1);
TL=FFTi(:,:,[3,4,5,6]);
TL=sum(TL,3)./4;
BL=FFTi(:,:,[7,8,9,10]);
BL=sum(BL,3)./4;

FFTt=cat(3,M,TL,BL);


   
B_M=dir('B_M*.jpg');  %%loads files can change to png or gif
B_Mfiles={B_M.name};
nfilesp=numel(B_Mfiles);

T_M=dir('T_M*.jpg');  %%loads files can change to png or gif
T_Mfiles={T_M.name};





for m=1:nfilesp
ImB_M{m}=imread(B_Mfiles{m});
ImT_M{m}=imread(T_Mfiles{m});
end

     
%%
close all

figure('rend','painters','pos',[100 100 1000 600])
FFTnorm=FFTt;%./max(max(max(FFTi)));
%FFTnorm=FFTi;%./mean(mean(mean(FFTi)))

subplot(2,3,3)
imagesc(ImT_M{1,1});
axis image;set(gca,'Yticklabel','') ;set(gca,'Xticklabel','')
set(gca,'XTick',0:LY(end):LY(end));set(gca,'YTick',0:LX(end):LX(end));
hold on

subplot(2,3,6)
imagesc(ImB_M{1,1});
axis image;set(gca,'Yticklabel','') ;set(gca,'Xticklabel','')
set(gca,'XTick',0:LY(end):LY(end));set(gca,'YTick',0:LX(end):LX(end));
hold on



Hp=H_u( H_u>=0 );
Hn=flip(H_u( H_u<0 ));

for i=1:1:length(H_u)
i=i

subplot(2,3,3)
imagesc(ImT_M{1,i});

subplot(2,3,6)
imagesc(ImB_M{1,i});



subplot(2,3,[1,2,4,5])
imagesc(H,f,FFTnorm(:,:,1))
set(gca,'YDir','normal')
colormap(map);caxis([0 1]);colorbar
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres/2:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres/2:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
set(gca,'FontSize',12);
hold on

XX=xline(H_u(i),'w:','LineWidth',2);
sgtitle([num2str(H_u(i),'%03.f'),' mT ']);



%saveas(gcf,'results/FMR_sep.png')


if save_png==1
        ino = sprintf('%04d_',i);
if H_u(i)<0;namepre = sprintf('n');end
if H_u(i)>=0;namepre = sprintf('p');end
        namehi = sprintf('%04.0f',(H_(i)));
        nameunit = 'mT.png';
        name = [dir,ino,namepre,namehi, nameunit];
    saveas(gcf,name); 
end
    
if giffy==1
          frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if i == 1
          imwrite(imind,cm,[pre '/' pre '_field-cycle.gif'],'gif', 'Loopcount',inf,'DelayTime', delay);
      else
          imwrite(imind,cm,[pre '/' pre '_field-cycle.gif'],'gif','WriteMode','append','DelayTime', delay);
      end
      end

if save_vid_time==1
F(i) = getframe(gcf);
else
end
    
   delete(XX);
   %drawnow

end

if save_vid_time==1
timevideo=[pre '/' pre '_field-cycle.avi'];
video = VideoWriter(timevideo,vfiletype);
video.FrameRate = fr;
open(video)
writeVideo(video,F);
close(video)  
clear video; clear timevideo; clear F; clear frame;
else
end



%%


%%
close all

figure('rend','painters','pos',[100 100 1000 600])

FFTnormT=TL;%./max(max(max(FFTi)));
%FFTnorm=FFTi;%./mean(mean(mean(FFTi)))
FFTnormB=BL;%./max(max(max(FFTi)));
%FFTnorm=FFTi;%./mean(mean(mean(FFTi)))

subplot(2,3,3)
imagesc(ImT_M{1,1});
axis image;set(gca,'Yticklabel','') ;set(gca,'Xticklabel','')
set(gca,'XTick',0:LY(end):LY(end));set(gca,'YTick',0:LX(end):LX(end));
hold on

subplot(2,3,6)
imagesc(ImB_M{1,1});
axis image;set(gca,'Yticklabel','') ;set(gca,'Xticklabel','')
set(gca,'XTick',0:LY(end):LY(end));set(gca,'YTick',0:LX(end):LX(end));
hold on




Hp=H_u( H_u>=0 );
Hn=flip(H_u( H_u<0 ));

for i=1:1:length(H_u)


subplot(2,3,3)
imagesc(ImT_M{1,i});

subplot(2,3,6)
imagesc(ImB_M{1,i});




subplot(2,3,[1,2])
imagesc(H,f,FFTnormT(:,:,1))
set(gca,'YDir','normal')
colormap(map);caxis([0 1]);%colorbar
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
set(gca,'FontSize',12);
hold on

XX=xline(H_u(i),'w:','LineWidth',2);
sgtitle([num2str(H_u(i),'%03.f'),' mT ']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,3,[4,5])
imagesc(H,f,FFTnormB(:,:,1))
set(gca,'YDir','normal')
colormap(map);caxis([0 1]);%colorbar
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
set(gca,'FontSize',12);
hold on

YY=xline(H_u(i),'w:','LineWidth',2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%saveas(gcf,'results/FMR_sep.png')


if save_png==1
        ino = sprintf('%04d_',i);
if H_u(i)<0;namepre = sprintf('n');end
if H_u(i)>=0;namepre = sprintf('p');end
        namehi = sprintf('%04.0f',abs(H_u(i)));
        nameunit = 'mT.png';
        name = [dir,ino,namepre,namehi, nameunit];
    saveas(gcf,name); 
end
    
if giffy==1
          frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if i == 1
          imwrite(imind,cm,[pre '/' pre '_field-cycle-layers.gif'],'gif', 'Loopcount',inf,'DelayTime', delay);
      else
          imwrite(imind,cm,[pre '/' pre '_field-cycle-layers.gif'],'WriteMode','append','DelayTime', delay);
      end
end

if save_vid_time==1
F(i) = getframe(gcf);
else
end
    
   delete(XX);delete(YY);
   %drawnow

end

if save_vid_time==1
timevideo=[pre '/' pre '_field-cycle-layers.avi'];
video = VideoWriter(timevideo,vfiletype);
video.FrameRate = fr;
open(video)
writeVideo(video,F);
close(video)  
clear video; clear timevideo; clear F; clear frame;
else
end

end
%%

