function test_collewijn

% collewijn('test_data.mat',true); % real data horizontal 5sec period
% collewijn('test_data2.mat',true); % no saccade tags
%%
load test_data2.mat

t_amp = 109.4;

t_rate = 1/sscanf(period,'%f');

t_phase = -0.5;

trials.eye(:,2) = t_amp*sin(t_phase + 2*pi*t_rate*(1:length(trials.eye(:,2)))/sample_rate);

save test_data3.mat

collewijn('test_data3.mat',true); % synthetic ideal response
