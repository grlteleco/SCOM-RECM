%% 
close all
clear

%% Data
users = 9604 + 1067 + 8570 + 77131;
usersLTE = 295957;
users = users + usersLTE;
concurrency = 0.17;

fixTelErlangs = 0.15;
fixTelDuration = 100; %s
fixTelLambda = fixTelErlangs/fixTelDuration*users*concurrency;


vidConfErlangs = 0.01;
vidConDuration = 30*60; %s
vidConLambda = 4*vidConfErlangs/vidConDuration*(users - usersLTE)/10*concurrency;

totalLambda = fixTelLambda + vidConLambda;
%% Simulation: Fixed telephony

functions = ["HSS" ,"MGCF", "MGW" ,"SGW", "MRF"];
maxNumberOf = [500 10000 20000 10000 20000]; %HSS MGCF MGW SGW MRF
worstCaseCalls = [2 12.375 3755.25 6.4475 90013]; %HSS MGCF MGW SGW MRF
servingTime = [120 170 20 170 20].*1e-3; %HSS MGCF MGW SGW MRF
lambda = [fixTelLambda fixTelLambda fixTelLambda fixTelLambda vidConLambda]; %HSS MGCF MGW SGW MRF
GoS = 0.01;
finalNumberOf = zeros(1,size(maxNumberOf,2));

for i = 1 : size(worstCaseCalls,2)
    
    Eb = ones(1,maxNumberOf(i));
    Ec = ones(1,maxNumberOf(i));
    meanWaitingTime = zeros(1,maxNumberOf(i));
    A = lambda(i) * worstCaseCalls(i) * servingTime(i);
    
    for N = ceil(A):maxNumberOf(i)

        k = 0:N-1;
        
        % Erlang C: Probability of waiting
        auxVectorEc = exp(gammaln(N+1) - gammaln(k+1) + (k - N)*log(A));
        Ec(N) = 1./(1 + sum(auxVectorEc));
        meanWaitingTime(N) = Ec(N) * servingTime(i)/(N-A);
        
        if(Ec(N) < 0.01)
            break;
        end
    end
    
    finalNumberOf(i) = find(Ec < GoS,1);
    disp(strcat("Number of ",functions(i),": ",int2str(finalNumberOf(i)),". Mean waiting time: ",num2str(meanWaitingTime(finalNumberOf(i)))))
    
    % figure
    % stem(Eb)
    % xlim([0 maxNumberOf(i)])
    % title('Fixed telephony Erlang B: Probability of blocking')
    % xlabel(strcat('Number of ',functions(i))); ylabel('Probability')
    % 
    figure
    stem(Ec)
    xlim([ceil(A-1) finalNumberOf(i)])
    title('Fixed telephony Erlang C: Probability of waiting in a queue')
    xlabel(strcat("Number of ",functions(i))); ylabel('Probability')
    % 
%     % figure
%     % stem(meanWaitingTime)
%     % xlim([0 maxNumberOf(i)])
%     % title('Fixed telephony Erlang c: Mean waiting time')
%     % xlabel(strcat('Number of ',functions(i))); ylabel('Seconds')

end



% %% Videoconference
% 
% maxNumberOfHSS = 5;
% Eb = zeros(1,maxNumberOfHSS);
% Ec = zeros(1,maxNumberOfHSS);
% meanWaitingTime = zeros(1,maxNumberOfHSS);
% 
% for N = 1:maxNumberOfHSS
%     
%     k = 0:N;
% 
%     % Erlang B: Probability of blocking
%     auxVectorEb = vidConfErlangs.^k./factorial(k);
%     Eb(N) = (vidConfErlangs^N/factorial(N))/(sum(auxVectorEb));
%     
%     % Erlang C: Probability of waiting
%     auxVectorEc = vidConfErlangs.^k./factorial(k) + vidConfErlangs.^N/factorial(N)*(N/(N-vidConfErlangs));
%     Ec(N) = vidConfErlangs.^N/factorial(N)*(N/(N-vidConfErlangs))/sum(auxVectorEc);
%     meanWaitingTime(N) = Ec(N) * vidConDuration/(N*(1-vidConfErlangs));
%     
% end
% 
% figure
% stem(Eb)
% xlim([0 maxNumberOfHSS])
% title('Videoconference Erlang B: Probability of blocking')
% xlabel('Number of HSS'); ylabel('Probability')
% 
% figure
% stem(Ec)
% xlim([0 maxNumberOfHSS])
% title('Videoconference Erlang C: Probability of waiting in a queue')
% xlabel('Number of HSS'); ylabel('Probability')
% 
% figure
% stem(meanWaitingTime)
% xlim([0 maxNumberOfHSS])
% title('Videoconference Erlang c: Mean waiting time')
% xlabel('Number of HSS'); ylabel('Seconds')
