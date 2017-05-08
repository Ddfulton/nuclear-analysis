ATPstats = [0, 0];
ATPdiscarded = 0;

lapse = [0 0 0]; % [timestep eccentricity area]
lapse = cell(25, 2);

nFiles = length(dir('timelapses/*.mat'));

for j = 1:nFiles
    
    file = strcat('timelapses/', int2str(j), '.mat');
    load(file);
    
    for i = 1:size(data, 1)
       current = data(i, :);
       slice = data{i, 1};
       current = current{1, 2};
       res = processBinary(current);
       area = res(1)*64*64/1000;
       ecc = res(2);

       % Area
       lapse{slice, 1} = [lapse{slice, 1} area];

       % Eccentricity
       lapse{slice, 2} = [lapse{slice, 2} ecc];
       
       % Error
    end
end

averageAreas = [0 0 0];
averageEccs = [0 0 0];

for i = 1:size(lapse, 1)-3
    areas = lapse{i, 1};
    eccs = lapse{i, 2};
    averageAreas = [averageAreas; i, mean(areas), std(areas)/2];
    averageEccs = [averageEccs; i, mean(eccs), std(eccs)/2];
end


figure(1);
axis([0 20 0 1]);
errorbar(averageEccs(2:end, 1), averageEccs(2:end, 2), averageEccs(2:end, 3));
hold on;
plot(averageEccs(2:end, 1), averageEccs(2:end, 2), 'LineWidth', 7), title('Average Eccentricities of 25 Nuclei After Treatment with Azide over Twenty Minutes', 'FontSize', 14), xlabel('Time (minutes)', 'FontSize', 14), ylabel('Average Eccentricity', 'FontSize', 14);
hold off;

figure(2);
axis([0 20 0 10000]);
errorbar(averageAreas(2:end, 1), averageAreas(2:end, 2), averageAreas(2:end, 3));
hold on;
plot(averageAreas(2:end, 1), averageAreas(2:end, 2), 'LineWidth', 7), title('Average Areas of 25 Nuclei After Treatment with Azide over Twenty Minutes', 'FontSize', 14), xlabel('Time (minutes)', 'FontSize', 14), ylabel('Average Area (um^2)', 'FontSize', 14
);
hold off;