clc;
clear;
%% Part A) Initialising the variables that will be used and placing the prey/predators in the Environment
BoundariesOfEnviromment  = 10^2;
prey = 50; %preys
predators = 20; %predators

df=[-1 1 1 -1]; %degrees of freedom
Environment = zeros(BoundariesOfEnviromment);
M_Environment=ones(BoundariesOfEnviromment); 
%A NxN environment matrix to be used for the 4 available directions(up down
%left righ)



preyBreedTime      =  10;
predatorBreedTime  =  15;
predatorStarveTime = 20;

%A simple way to add the prey and predators randomly on available(free/0)
%indices
valid_ind = find(Environment==0);
n = length(valid_ind);
idx = valid_ind(randperm(n,prey));
Environment(idx) = 1;
valid_ind = find(Environment==0);
n = length(valid_ind);
idx = valid_ind(randperm(n,predators));
Environment(idx) = -1;


Hunger = 1*(Environment==-1);%Tracks hunger for each predator



iter = 1;
iter_max = 10000;
prey_ev = zeros(1,iter_max);
pred_ev = zeros(1,iter_max);
popu_ev = zeros(1,iter_max);

prey_ev(1) = prey;
pred_ev(1) = predators;
popu_ev(1) = (prey+predators);

%% While loop that simulates the main parts of the simulation like movement hunger and birth
while prey>0 && iter<iter_max && predators>0
    
    
    
    if iter == iter_max/2
        y = [prey, predators, (prey+predators)];
    end
    
    
    
    
    
    satisfied_predators = zeros(BoundariesOfEnviromment);
    %See if any predator is near a prey so he can move and eat them
    %Eating a prey resets the Hunger timer to 0
    
    %By using circshift and a combinations of masks we can easily check if
    %a prey is near a predator so the latter can move and eat them
    
    for k = 1:length(df)
        
        predator_index = (Environment == -1) & (satisfied_predators==0) ;
        predator_right = circshift(predator_index,1,2);
        predator_left  = circshift(predator_index,-1,2);
        predator_down  = circshift(predator_index,1,1);
        predator_up    = circshift(predator_index,-1,1);
        adj_prey = ...
            (Environment.*(circshift(predator_index,df(k),mod(k,2)+1))) == 1;
        old_pred = ...
            (Environment.*(circshift(adj_prey,-df(k),mod(k,2)+1))) == -1;
        adj_prey_index = (adj_prey~=0);
        old_pred_index = (old_pred~=0);
        Environment(adj_prey_index) = -1;
        Hunger(adj_prey_index) = 0;
        Environment(old_pred_index) =  0;
        Hunger(old_pred_index) = 0;
        satisfied_predators(adj_prey_index) = 1;
    end
    
    
    
    
    
    
    
    %A random matrix (M_Environment) is initialized with values from 1-4
    %selected randomly so a predator/prey  can move on the desired
    %direction. This is achieved by using a combination of the 
    %dF(degrees of Freedom)vector and the modulo operator checking each
    %direction iteratively. By using the mask (Environment==0) all free
    %positions are filtered and have a value of 1(0 for occupied indices)
    %and after multiplying them with M_Enviroment circshift a mask with all
    %predators/prey able to move is created.The T_A matrix basically saved
    %the previous positions of the prey/predators that moved so they can be
    %removed from the main matrix(Environment). 

    M_Environment=ceil(4*(rand(BoundariesOfEnviromment)));
    for i = 1:length(df)
        mask = (Environment==0).*(  circshift(M_Environment==i,df(i),mod(i,2)+1)) ;
        T_A =  Environment.*circshift(mask,-df(i),mod(i,2)+1);
        Environment= Environment - T_A;
        Environment = Environment + circshift(T_A,df(i),mod(i,2)+1);
        
        T_Hunger = Hunger.*circshift(mask,-df(i),mod(i,2)+1);
        Hunger = Hunger - T_Hunger;
        Hunger = Hunger + circshift(T_Hunger,df(i),mod(i,2)+1);
    end
    
    pred_indices = find(Environment==-1);
    Hunger(pred_indices) = Hunger(pred_indices) + 1;
    dead_predators = Hunger(pred_indices) >= predatorStarveTime;
    Environment(pred_indices(dead_predators)) = 0;
    Hunger(pred_indices(dead_predators)) = 0;
    
    
    
    %An if condition to check when prey/predator are meant to give birth.
    %Max prey is n/2 but they give birth only if they have available
    %indices near them.The loop goes on until n/2 "kids" are born or until
    %the degrees of freedom are exhausted.
    
    if mod(iter,preyBreedTime)==0
        prey_ind = Environment==1;
        max_prey = floor(prey/2);
        for j =1 :length(df)
            if max_prey == 0
                break;
            end
            new_prey = (Environment==0).*circshift(prey_ind,df(j),mod(j+1,2)+1);
            v = find(new_prey);
            v=v(randperm(length(v)));
            min_ind = min(length(v),max_prey);
            v(1:min_ind )  = 0;
            new_prey(v(v~=0)) = 0;
            Environment = Environment + new_prey ;
            max_prey = max_prey - min_ind;
        end
    end
    
    
    if mod(iter,predatorBreedTime)==0
        predator_ind = (Environment==-1);
        max_pred = floor(predators/2);
        for j =1 :length(df)
            if max_pred == 0
                break;
            end
            new_pred = -(Environment==0).*circshift(predator_ind,df(j),mod(j+1,2)+1);
            v = find(new_pred);
            v=v(randperm(length(v)));
            min_ind = min(length(v),max_pred );
            v(1:min_ind )  = 0;
            new_pred(v(v~=0)) = 0;
            Environment = Environment + new_pred;
            max_pred = max_pred - min_ind;
        end
    end
    
    
    %{
Global starvation timer
prey_after = numel(find(A==1));
if prey_after == prey_before
    starve_timer = starve_timer + 1;
    if starve_timer == predatorStarveTime
        disp("Predators die due to starvation");
    end
end
    %}
    
    
    
    
    
    prey = numel(find(Environment==1));
    predators = numel(find(Environment==-1));
    
    
    
    imagesc(Environment)
    cmap = [1 0 0; 1 1 1; 0 0 1];
    colormap(cmap)
    caxis([-1 1])
    drawnow;
    pause(0.005);
    iter = iter+1;
    
    
    prey_ev(iter) = prey;
    pred_ev(iter) = predators;
    popu_ev(iter) = (prey+predators);
    
end


%% Last part that plots the desired graphs
prey_ev = prey_ev(1:iter);
pred_ev = pred_ev(1:iter);
popu_ev = popu_ev(1:iter);

x = categorical({'Prey', 'Predators', 'Total population'});
x = reordercats(x,{'Prey', 'Predators', 'Total population'});
time = [1  (ceil(iter/2))  (iter)];
for i = 1:length(time)
    fi = figure;
    y = [prey_ev(time(i)), pred_ev(time(i)), popu_ev(time(i))];
    b1 = bar(x,y);
    title("Population at t=" + time(i) +"s")
    b1.FaceColor = 'flat';
    b1.CData(1,:) = [0 0 1];
    b1.CData(2,:) = [1 0 0];
    b1.CData(3,:) = [128, 0, 128] / 255;
    ylabel("Population");
end



figure;
x_axis  = 1:iter;
subplot(2,1,1);
title("Prey population over time")
plot(x_axis , prey_ev);
xlabel("Time");
ylabel("Prey");

subplot(2,1,2);
title("Predator population over time")
plot(x_axis , pred_ev);
xlabel("Time");
ylabel("Predators");



