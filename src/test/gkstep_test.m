% gkstep_test.m :
%
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Illustrate the effect of rounding-to-minus-infinity
% quantisation noise. The state variable form of a filter is:
%   x(k+1) = Ax(k) + Bu(k)
%   y(k)   = Cx(k) + Du(k)
% where u is the input, x is the state and y is the output.
% For rounding-to-minus-infinity rounding the quantisation
% noise is uniformly distributed in [0,1) with mean q/2 and
% variance q/3. Calculation of the state variable equations 
% with rounding-to-minus-infinity (floor) rather than
% rounding-to-nearest (round) is equivalent to a applying a
% q/2 step input to the round off noise transfer function 
% from each state to the output. Here, the step response is
% illustrated by adding the unit step output response of all
% the states in the filter at the output. 

test_common;

delete("gkstep_test.diary");
delete("gkstep_test.diary.tmp");
diary gkstep_test.diary.tmp

% Make a 3rd order Butterworth state variable filter. The
% filter is globally optimised so that diagonal elements of
% K, the state covariance matrix, are 1.0 ie: the states 
% are equally scaled
fc=0.05;
[n,d]=butter(3,2*fc);
[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
[Topt,Kopt,Wopt]=optKW(K,W,1);
ngopt=sum(diag(Kopt).*diag(Wopt));
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;

% Make a test signal
nsamples=100;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5; 
% Scale the quantisation step size, q, to 1
nbits=10;
u=round(u*2^(nbits-1));

% Filter the test signal, first with no rounding then 
% with rounding-to-minus-infinity
[y,xx]=svf(Aopt,Bopt,Copt,Dopt,u,"none");
[yfloor,xxfloor]=svf(Aopt,Bopt,Copt,Dopt,u,"floor");

% Find the total quantisation noise at the output then
% subtract 0.5 from the output noise to remove the 
% quantisation noise due to rounding-to-minus-infinity 
% of the output itself. 
state_output_noise=y-yfloor-0.5;

% Find the round off noise transfer function impulse 
% responses for each state in the filter. Each column
% is the state vector at time k
gk=zeros(nsamples,length(Copt));
gC=Copt;
for k=2:nsamples
  gk(k,:)=gC;
  gC=gC*Aopt;
end

% Integrate the impulse response to find the step response 
% of each state to the output
stepx=cumsum(gk,1);
% Find the sum of the state-to-filter-output step responses
unit_step=sum(stepx,2);
% Scale the unit_step by 0.5, the mean of the rounding-to-
% minus-infinity quantisation noise distribution.
state_step=0.5*unit_step;

% Plot the response of the state outputs, x, to a step of 0.5
% and the output noise due to the state outputs. 
plot((1:nsamples),[state_output_noise,state_step])
axis([1 nsamples]);
grid("on");
xlabel("Sample");
ylabel("Amplitude(bits)");
print("gkstep_test_noise","-dpdflatex");
close

% Done
diary off
movefile gkstep_test.diary.tmp gkstep_test.diary;
