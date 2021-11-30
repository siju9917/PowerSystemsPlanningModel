delimiterIn = ',';
headerlinesIn = 1;
hold on
B = importdata('TimeSeriesFinal.csv',delimiterIn);
plot(0.8*B.data)
plot(6253:6259,0.8*B.data(6253:6259),'LineWidth',7)
plot(8443:8449,0.8*B.data(8443:8449),'LineWidth',7)
plot(4063:4069,0.8*B.data(4063:4069),'LineWidth',7)
plot(1873:1879,0.8*B.data(1873:1879),'LineWidth',7)
title('Load Profile of 1 Year')
legend('Load','Summer','Fall','Spring','Winter')
xlabel('Time (hours)')
ylabel('Load (MW)')
savefig('/Users/simon/Desktop/GAMSFigs/loadProfile.fig')
hold off