% script to plot krige and confidence intervals for data

condPoints = r;
condVals = intensity;

uncondPoints = linspace(0,r(end),100)';

corFun = 'sexp';
lowerTheta = 0;
upperTheta = 20;

[theta,mu,sigma,lval] = maxLfun(condValues,condPoints,corFun,lowerTheta,upperTheta);

[krige,CIupper,CIlower] = krigeIt(condPoints,condValues,uncondPoints,corFun,mu,sigma,theta);

figure;
scatter(condPoints,condValues)
hold on
plot(uncondPoints,krige)


figure;
hold on
X = [uncondPoints; flipud(uncondPoints)];
Y = [CIlower; flipud(CIupper)];
Y(isnan(Y)) = 0;
h = fill(X',Y',[0.8,0.8,0.8]);
set(h,'EdgeColor','none')
plot(uncondPoints,krige,'color',[1 0 0],'LineWidth',2)
scatter(condPoints,condValues,'MarkerEdgeColor',[1 0 0],'LineWidth',2,'Marker','o','SizeData',50,'LineWidth',2,'MarkerFaceColor',[1,1,1]);
hold off
grid on
box on
