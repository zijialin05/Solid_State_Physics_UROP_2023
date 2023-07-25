clear all
close all

currentdirectory = pwd;
prompt = 'Type the title:';
pre = input(prompt,'s');mkdir(pre)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  dP"Yb  88""Yb 888888 88  dP"Yb  88b 88 .dP"Y8 
% dP   Yb 88__dP   88   88 dP   Yb 88Yb88 `Ybo." 
% Yb   dP 88"""    88   88 Yb   dP 88 Y88 o.`Y8b 
%  YbodP  88       88   88  YbodP  88  Y8 8bodP' 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% OPTIONS START
% REGION OPTIONS 

% region  =   [2,  21,     32,    35,    41,    38,    44,    47,    53,    50];
% regionname={'m','demag','T-TL','T-TR','T-BL','T-BR','B-TL','B-TR','B-BL','B-BR'};

%%%%%%%TRILAYER ISLAND
region=[32,44]
regionname={'T','B',}; 

%%HEATMAP
map='hot';
fonty=14;
fmin=0;fmax=14;fres=1;
Xmin=0;Xmax=60;Xres=10;
cmin=0;cmax=1;c_log=1;

% PLOT ALL FIELDS
plot_ALLFIELDS=1;
log_col_plot=1;

plot_SELECTFIELDS = 0;

set(0,'defaultfigurecolor',[1 1 1])

%% OPTIONS END

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 88""Yb 88   88 88     88         .dP"Y8 88 8b    d8     88 88b 88 888888  dP"Yb  
% 88__dP 88   88 88     88         `Ybo." 88 88b  d88     88 88Yb88 88__   dP   Yb 
% 88"""  Y8   8P 88  .o 88  .o     o.`Y8b 88 88YbdP88     88 88 Y88 88""   Yb   dP 
% 88     `YbodP' 88ood8 88ood8     8bodP' 88 88 YY 88     88 88  Y8 88      YbodP
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% PULL SIM INFO START
%import settings and data from table(s)
file = dir('table*.txt');
tabledata=[];
for i=1:length(file)
name = file(i).name;
table = importdata(name);
temp=table.data;
tabledata=cat(1,tabledata,temp);
end
% 
[HH,idx] = sort(tabledata(:,16));

tabledata = tabledata(idx,:);


%make a table with headings
tablenames=table.textdata;
Table=array2table(tabledata,'VariableNames',tablenames);



%get unique fields and times from data 
H=tabledata(:,16)./10;H_u=unique(H);H_l=length(H_u);
t=tabledata(:,1);t_u=t(1:length(t)/H_l);t_l=length(t_u);

% Time specifications for FFT to get frequency:
dt = mean(diff(t_u)).*1e9;
Fs = 1/dt; N = t_l;
dF = Fs/N; f = -Fs/2+dF:dF:Fs/2; 

Nx=tabledata(1,5); Ny=tabledata(1,6); Nz=tabledata(1,7); %pull cell number
cx=tabledata(1,8);cy=tabledata(1,9);cz=tabledata(1,10);  %pull cell size
LX=(cx:cx:cx*Nx)*1e9;LY=(cy:cy:cy*Ny)*1e9;LZ=(cz:cz:cz*Nz)*1e9;
%% PULL SIM INFO END

% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% 888888 888888 888888     888888 88 8b    d8 888888 
% 88__   88__     88         88   88 88b  d88 88__   
% 88""   88""     88         88   88 88YbdP88 88""   
% 88     88       88         88   88 88 YY 88 888888 
% % % % % % % % % % % % % % % % % % % % % % % % % % %  

%% FFT TIME START

R_l=length(region);

MDYN=[];
for i=1:R_l
    j=region(i);
temp=tabledata(:,j:j+2);
MDYN=cat(3, MDYN,temp);
end

MDYN=reshape(MDYN,t_l,H_l,3,R_l);
MDYN=permute(MDYN,[2,1,4,3]);

% % MDYN(H,t,region,comp)
Power=[];
    for i=1:3
    M=MDYN(:,:,:,i);
    M_fft=(fft(M,t_l,2));
    P_comp=abs(M_fft);
    Power=cat(4,Power,P_comp);
    end

Power=flip(Power(:,floor(t_l/2)+1:t_l,:,:),2);
PowerT=sqrt(Power(:,:,:,1).^2+Power(:,:,:,2).^2+Power(:,:,:,3).^2);
frequency=(f(floor(length(f)/2)+1:length(f)))';


%% FFT TIM END


% LOOP THROUGH REGIONS
for r=1:length(region)

% % % % % % % % % % % % % % % % % % % % % % % % % % %  
% 88  88 888888    db    888888 8b    d8    db    88""Yb 
% 88  88 88__     dPYb     88   88b  d88   dPYb   88__dP 
% 888888 88""    dP__Yb    88   88YbdP88  dP__Yb  88"""  
% 88  88 888888 dP""""Yb   88   88 YY 88 dP""""Yb 88    
% % % % % % % % % % % % % % % % % % % % % % % % % % %  

%% HEATMAP START
P=(PowerT(:,:,r))';
Pmax=max(max(P));
Pnorm=P/Pmax;

figure
imagesc(H_u, frequency,Pnorm)
set(gca,'YDir','normal')
colormap(map);%caxis([0 1]);colorbar
if c_log==1;set(gca,'colorscale','log');end
set(gca,'YLim',[fmin,fmax]);set(gca,'YTick',fmin:fres:fmax);
set(gca,'xLim',[Xmin,Xmax]);set(gca,'XTick',Xmin:Xres:Xmax);
xlabel('\mu_{0}H (mT)');ylabel('frequency (GHz)');
set(gca,'FontSize',fonty);
title(regionname(r))
nameunit = '.png';
name=[pre '/' pre ' '  char(regionname(r)) ' HEATMAP ' nameunit];
saveas(gcf,(name))

%% HEATMAP END

% % % % % % % % % % % % % % % % % % % % % % % % % % %  
%    db    88     88     888888 88 888888 88     8888b.  .dP"Y8 
%   dPYb   88     88     88__   88 88__   88      8I  Yb `Ybo." 
%  dP__Yb  88  .o 88  .o 88""   88 88""   88  .o  8I  dY o.`Y8b 
% dP""""Yb 88ood8 88ood8 88     88 888888 88ood8 8888Y"  8bodP' 
% % % % % % % % % % % % % % % % % % % % % % % % % % %  

%% ALL FIELDS START

Lmap=jet(H_l)
fig = figure;
fig.Position = [100 100 720 1080];

for i=1:H_l
    if log_col_plot==1;P=log(Pnorm(:,i))+i;end
    if log_col_plot==0;P=(Pnorm(:,i))+i;end
plot(frequency,P ,'Color',Lmap(i,:),'LineWidth',2)
ylabel('Power (au)');xlabel('frequency (GHz)');
set(gca,'XLim',[fmin,fmax]);set(gca,'XTick',fmin:fres:fmax);
set(gca,'Color','k')
set(gca,'FontSize',fonty);
hold on
j=rem(i,5)-1
if j==0 text(frequency(end)+0.1,P(end),[num2str(H_u(i)),'mT'],'Color',Lmap(i,:)); end

end
set(gcf,'InvertHardCopy','Off');
title(regionname(r))
name=[pre '/' pre ' '  char(regionname(r)) ' ALLFIELDS ' nameunit];
saveas(gcf,(name))

%% ALL FIELDS END

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% .dP"Y8 888888 88     888888  dP""b8 888888     888888 88 888888 88     8888b.  .dP"Y8 
% `Ybo." 88__   88     88__   dP   `"   88       88__   88 88__   88      8I  Yb `Ybo." 
% o.`Y8b 88""   88  .o 88""   Yb        88       88""   88 88""   88  .o  8I  dY o.`Y8b 
% 8bodP' 888888 88ood8 888888  YboodP   88       88     88 888888 88ood8 8888Y"  8bodP' 
% % % % % % % % % % % % % % % % % % % % % % % % % % %  

%% SELECT FIELDS START

if plot_SELECTFIELDS == 1

% enter fields yoiu want to plot individually
prompt = 'Fields to plot [H1,H2,H3,...,Hn]';
H_user = input(prompt) 

Lmap=jet(length(H_user));
%find indices
A = repmat(H_user,[1 length(H_u)]);
[Value,closestIndex] = min(abs(A-H_u));

%plot figure
fig = figure;
fig.Position = [100 100 1080 720];
for i=1:length(H_user)
P=Pnorm(:,closestIndex(i))
plot(frequency,P,'Color',Lmap(i,:),'LineWidth',2)
set(gca,'FontSize',fonty);
ylabel('Power (au)');xlabel('frequency (GHz)');
set(gca,'XLim',[fmin,fmax]);set(gca,'XTick',fmin:fres:fmax);
hold on
end
title(regionname(r))
leg=legend(num2str(H_user'))
title(leg,'\mu_{0}H (mT)')

%save figure
filename=num2str(H_user)
nameunit = '.png';
name=[pre '/' pre ' '  char(regionname(r)) ' ' filename ' SELECT FIELDS ' nameunit];
saveas(gcf,(name))

end
%% SELECT FIELDS END
end