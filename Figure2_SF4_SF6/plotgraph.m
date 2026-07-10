function g = plotgraph (average, sem, mpi,gtitle)
average = cell2mat (average(:,1:mpi));
sem = cell2mat(sem(:,1:mpi));
errorbar(1:mpi,average(1,1:mpi),sem(1,1:mpi),'-r','LineWidth',1.5)
hold on
errorbar(1:mpi,average(2,1:mpi),sem(2,1:mpi),'-k','LineWidth',1.5)
xticks(1:mpi)
str = cell(1,mpi);
for ii = 1:mpi
str {ii} = strcat(num2str(ii),'mpi');
end
xticklabels(str)
% xticklabels({'1mpi','2mpi','3mpi','4mpi','5mpi','6mpi','7mpi'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
legend('PFF','Saline','Location','northwest')
title(gtitle,'FontSize',15)
end
