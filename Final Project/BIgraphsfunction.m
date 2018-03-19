function [] = BIgraphsfunction(UKinput,IREinput)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

UK=readtable(UKinput);
IRE=readtable(IREinput);
figureNumScatter=12;
figureNumBins=22; 
for j=[1,2]
 if j==1
     % for the Eastern Loop
     s=UK;
     pointColour='xblack';
     barColour='blue';
     
 else
     % Western loop
     s=IRE;
     pointColour='.red';
     barColour='yellow';
     
 end
%Next, the relevant data is retrieved. As we want precipitation per day, and months are different lengths, we calculate the number of days each reading was taken over, and use this to determine the average precipitation per day (note that we have to do this via dividing total precipitation by number of days, as we do not have any more temporal resolution than this.
%retrieving relevant data
d=datenum(s.Date,'yyyy-mm-dd');
H3=s.H3;
H2=s.H2;
O18=s.O18;

% days in month
numdays=(datenum(s.EndOfPeriod, 'yyyy-mm-dd')- datenum(s.BeginOfPeriod,'yyyy-mm-dd')+1);

% precipitation per day
pppday=s.Precipitation./numdays;
%First, the scatter plot is plotted to visualize the unbinned data first and to decide on the bin size.
% see a scatter plot of the data
f1=figure(figureNumScatter);
%figure
hold on
plotObjectpppD(j)=plot(pppday,H2,pointColour);

hold off
xlabel('Precipitation rate (mm per day)')
ylabel('\delta D')
%In the figure we are trying to reproduce, they use bins of 5, so we will as well. However, we see that their final bin stretches to infinity, so we will see if we can incorporate this as well.
% deciding our bin sizes
Edges=[0,2,4,6,8,Inf];
%To do these steps, we must discretize the  data by its relevant precipitation per day data.

% finding out which deltaH2s fall in each ppt/day
[pppdaybin,Edge]= discretize(pppday,Edges);

% pppdaybin= which 'bin' each pppday in the array falls in
% to get the array of deltaH2 for each bin
%We then use a loop in order to sparate out each binned set of data
for i=1:(length(Edge)-1)
    
% using a structure as it is easier to use with loops
% making the struct separated by bin

H2binned(i).H2=H2(pppdaybin == i);
end
%And we use another loop in order to find the means for each bin
for i=1:(length(Edge)-1)
% finding the mean of these binned deltaH2 (along with the standard deviations)
    H2binned(i).mean = nanmean(H2binned(i).H2);
    H2binned(i).error = nanstd(H2binned(i).H2);
end
%Whilst structures generally work more quickly with loops, arrays are slightly easier to do basic data manipulation with, so we quickly convert the data back into an array
for i=1:(length(Edge)-1)
% switching these back to an array, so we can more conveniently use this data (ouside of loops)
    H2binnedmeans(i)=H2binned(i).mean;
    H2binnedmeanstandarderror(i)=(H2binned(i).error)./sqrt(length(H2binned(i).H2));
end
%As we are trying to reproduce figure 10, and so would be plotting the mean  binned, versus the midvalue of each bin, we first need to find the midvalue. (Note for the last bin, we just add the first bins mid-value to the beggining of the last bins first edge, as the last bi stretches all the way to infinity)
% getting an array of the midvalues and creating an array of the start and end points of each bin, and then mean them

MidEdge(1,:)=Edge(1:(length(Edge)-1));
MidEdge(2,:)=Edge(2:length(Edge));
MidEdge=mean(MidEdge);
%Redefining the mid edge for the final bin
MidEdge(length(Edge)-1)=MidEdge(1)+Edge(length(Edge)-1);

%Plotting the bar graph  vs. precipitation rate. We use the bar function to produce similar bars as in figure 10. We also do not want the bars to overlay each other, so adjust their position depending on which loop cycle we are on
% plotting the graph, and use 'bar' function to plot as bars (as in the original paper)

if j==1
% shifting the bars for the first loop (East) to the positive
    MidEdgeShift=-0.5;
else
% and the bars for the second loop (West) to the negative
    MidEdgeShift=0.5;
end 
% plotting a bar graph
f2=figure(figureNumBins);
%Here we decided to try to make the graph a little prettier
% including earlier calculated shift
pointPosn=MidEdge+MidEdgeShift;
hold on

% creating a bar object so we can edit its properties
b(j)=bar(pointPosn,H2binnedmeans);

% We adjust its width to allow us to see both bars at once
b(j).BarWidth=0.4;
b(j).FaceColor=barColour;
%We also want to include errors, so we create an error bars object
e=errorbar(pointPosn,H2binnedmeans,H2binnedmeanstandarderror);
%And remove the line and points (as we already have our bars
e.LineStyle='none';
e.Marker='none';

%And include all necesary details for a graph (title, axes labels, etc)
title ('Delta Deuterium vs. Precipitation Rate: Bar Graph')

xlabel('Precipitation rate (mm per day)')
ylabel('\delta D (per mil)')
xticklabels(Edges)
xlim([0,Edges(length(Edges)-1)+Edges(2)])
grid on
hold off

end
legend (b,'Britain', 'Ireland', 'Location', 'southwest' )
legend (plotObjectpppD,'UK', 'Ireland')

end

