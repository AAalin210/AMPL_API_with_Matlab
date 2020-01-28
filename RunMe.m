% ==============================================================================
%  MATLAB Source Codes for the book "Cooperative Dedcision and Planning for
%  Connected and Automated Vehicles" published by Mechanical Industry Press
%  in 2020.
% ��������������Эͬ������滮�������鼮���״���
%  Copyright (C) 2020 Bai Li
%  2020.01.28
% ==============================================================================
%  �ڶ���. 2.3.5С��. ����AMPL API�ӿ���Matlab������ֱ�����򵥵ĳ����켣�滮����
%  �����ӻ������Ż����
% ==============================================================================
%  ��ע��
%  1. ��x��y�����⣬�������߱����ĵ�������ʾ��ʽ������ƣ�
%  2. �����н��ܵı�׼������ȣ����ļ������ļ������������٣������Ƴ��˲������õ��ļ�
% ==============================================================================
close all;
clc;
% ���AMPL API·��
addpath(genpath('amplapi'));
setupOnce;
% �켣�滮������ز�������
param.K = 3;
param.Nfe = 10;
param.L_wheelbase = 2.8;
param.a_max = 0.3;
param.v_max = 2.0;
param.phy_max = 0.72;
param.w_max = 0.54;
% ����һ��ampl API����
ampl_ = AMPL;
% ����NLP�����еĲ���
ampl_.eval(['param Nfe := ',num2str(param.Nfe),';']);
ampl_.eval(['param L_wheelbase := ',num2str(param.L_wheelbase),';']);
ampl_.eval(['param a_max := ',num2str(param.a_max),';']);
ampl_.eval(['param v_max := ',num2str(param.v_max),';']);
ampl_.eval(['param phy_max := ',num2str(param.phy_max),';']);
ampl_.eval(['param w_max := ',num2str(param.w_max),';']);
% ���ļ������NLPģ�ͷǿɱ䲿��
ampl_.read('planning_fixed_part.mod');
% ��ʼ��(ע���˴�ֻ�ǽ��ܳ�ʼ����ֵ���д����ʵ�ʳ�ʼ����������2.4�ڽ���)
% ��x����Ϊ����������Ԫ������Ϊ0.01*(1+����+����)
x = ampl_.getVariable('x');
for ii = 1 : param.Nfe
    for jj = 0 : param.K
        instance = x.get(ii,jj);
        instance.setValue(0.01 * (1 + ii + jj));
    end
end
% ָ����ѧ�滮���������ΪIPOPT
ampl_.setOption('solver','ipopt');
% ��ʼ���NLP����
ampl_.solve;
% ��������󵼳��Ż��õ��ľ��߱���x��y��
x = ampl_.getVariable('x');
y = ampl_.getVariable('y');
tf = ampl_.getVariable('tf');
optimized_x = [];
optimized_y = [];
optimized_tf = tf.get().value;
for ii = 1 : param.Nfe
    for jj = 0 : param.K
        optimized_x = [optimized_x, x.get(ii,jj).value];
        optimized_y = [optimized_y, y.get(ii,jj).value];
    end
end
% �����Ż���Ĺ켣
precision_level = 0.01;
[~, precise_x] = GeneratePreciseProfileFromCollocationGrids(optimized_x, param.Nfe, optimized_tf, precision_level, 0);
[~, precise_y] = GeneratePreciseProfileFromCollocationGrids(optimized_y, param.Nfe, optimized_tf, precision_level, 0);
figure(1)
set(0,'DefaultLineLineWidth',3);
plot(precise_x,precise_y,'k');
axis equal; box on; grid on; axis tight;
xlabel('x axis / m','Fontsize',16,'FontWeight','bold');
ylabel('y axis / m','Fontsize',16,'FontWeight','bold');
set(gca,'FontSize',12,'FontWeight','bold');
title('�����˶��켣');
% �������ۺ������Ż�ֵ������ӡ����Ļ��
cost_val = ampl_.getObjective('cost_function'); % ��Ҫ��mod�о������һ��
fprintf('Cost function value = %f\n', cost_val.value);
% �м����Ҫ�ر�AMPL���󣬷�������ռ���ڴ���Դ
ampl_.close;