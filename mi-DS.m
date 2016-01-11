clc; clear;

[filename,pathname]=uigetfile('.xls','Select training data.');

full_fn=strcat(pathname,filename);
x=xlsread(full_fn);
nunq_bags=numel(unique(x(:,1)));

% Step 1: Making pos and neg tables
pos_index= x(:,end)==1;
neg_index= x(:,end)==0;

pos_table=x(pos_index,2:end-1); % leave first and last columns (1st column contains bag info and last class info)
pos_tab_bag_tag=x(pos_index,1);
neg_table=x(neg_index,2:end-1);
neg_tab_bag_tag=x(neg_index,1);

% Step 2a: Making G_pos
G_pos=[]; % Gpos table
[Nd_pos,k]=size(pos_table);
d1=pos_table(1,:); % first instance of pos table
tmp=d1;
g=d1;
G_pos=g;
count=1;
count_rep=1;

for j=2:Nd_pos    
    dj=pos_table(j,:); % jth row of data    
    for kk=1:k
        if dj(kk)~=tmp(kk)
            tmp(kk)=9999;      % here 9999 = *      
        end        
    end    
    if sum(tmp~=9999)>=2
        g=tmp;        
        G_pos(end,:)=g;
        count_rep=count_rep+1;
        count(end,:)=count_rep; % Counts how many instance from pos table does every Gpos cover
    else
        tmp=dj; % setting temp to new row
        g=dj;
        G_pos=[G_pos;g];
        count_rep=1; % reset count_rep to 1
        count=[count;1];
    end
end
G_pos=[G_pos,count];

% % Step 2b: Making G_neg
G_neg=[]; % Gneg table
[Nd_neg,k]=size(neg_table);
d1=neg_table(1,:); % first instance of pos table
tmp=d1;
g=d1;
G_neg=g;
count=1;
count_rep=1;

for j=2:Nd_neg    
    dj=neg_table(j,:); % jth row of data    
    for kk=1:k
        if dj(kk)~=tmp(kk)
            tmp(kk)=9999;      % here 9999 = *      
        end        
    end    
    if sum(tmp~=9999)>=2
        g=tmp;        
        G_neg(end,:)=g;
        count_rep=count_rep+1;
        count(end,:)=count_rep; % Counts how many instance from neg table does every Gneg cover
    else
        tmp=dj; % setting temp to new row
        g=dj;
        G_neg=[G_neg;g];
        count_rep=1; % reset count_rep to 1
        count=[count;1];
    end
end
G_neg=[G_neg,count];

% Step 3a: Number of unique values each attribute takes (Same for pos and neg tables)
for i=1:k
    n_unq(1,i)=numel(unique(x(1:end,i+1),'rows'));
end

% Step 3b: Make similarity matrix for Gpos table
[nrow_Gpos,~]=size(G_pos); % number of rows in G_pos table
for i=1:nrow_Gpos
    for j=1:k
       sim_mat(i,j)= sum(G_pos(i,j)==pos_table(:,j));
    end
end
ac_pos_sim_measure=sim_mat.*repmat(n_unq,nrow_Gpos,1);

% % Step 3c: Make similarity matrix for Gneg table
[nrow_Gneg,~]=size(G_neg); % number of rows in G_neg table
for i=1:nrow_Gneg
    for j=1:k
       sim_mat(i,j)= sum(G_neg(i,j)==neg_table(:,j));
    end
end
ac_neg_sim_measure=sim_mat.*repmat(n_unq,nrow_Gneg,1);

% Step 4a: Making Pos rules from Gpos table
set_of_pos_rules=[];
for i=1:nrow_Gpos
    [~,sort_id]=sort(ac_pos_sim_measure(i,:),2,'descend'); 
    rule=G_pos(i,sort_id(1));   % create 1st rule
    rule_vec=-5555*ones(1,k);   % initialize rule vector
    rule_vec(1,sort_id(1))=rule;% vector of 1st rule
    
% Check if this rule is covered in Gneg table
    if ismember(rule,G_neg(:,sort_id(1)),'rows') % if rule is covered
        % add more selectors and check again
        for j=2:k  % next highest value
            if ac_pos_sim_measure(i,sort_id(j))==0
                break % stop
            else % create new rule
                new_rule=G_pos(i,sort_id(j));
                rule_vec(sort_id(j))=new_rule;
                ne_index=rule_vec~=-5555;
                ne_rule=rule_vec(1,ne_index);
                                                    
                if ismember(ne_rule,G_neg(:,ne_index),'rows')
                   continue
                else
                    break % accept rule
                end
            end
        end
    end 
    set_of_pos_rules=[set_of_pos_rules;rule_vec];
end

set_of_unique_pos_rules=unique(set_of_pos_rules,'rows');
[n_unq_rules,~]=size(set_of_unique_pos_rules);

% Check how many instances each rule covered
for i=1:n_unq_rules
    ne_rules=sum(set_of_unique_pos_rules(i,:)~=-5555);
    for kj=1:Nd_pos
        nmatch_index= pos_table(kj,:)==set_of_unique_pos_rules(i,:);
        if sum(nmatch_index)==ne_rules
            match_count(kj,1)=1;
            pos_bags_matched(kj,1)=pos_tab_bag_tag(kj);
        end
    end
    
    nmatch(i,1)=sum(match_count);
    pos_bag_match_cell{i,1}=unique(nonzeros(pos_bags_matched));
    pos_bags_matched=[];
    match_count=[];
end
R_pos_table=[set_of_unique_pos_rules,nmatch];

% Step 4b: Making rules from Gneg table
set_of_neg_rules=[];
for i=1:nrow_Gneg
    [~,sort_id]=sort(ac_neg_sim_measure(i,:),2,'descend'); 
    rule=G_neg(i,sort_id(1));   % create 1st rule
    rule_vec=-5555*ones(1,k);   % initialize rule vector
    rule_vec(1,sort_id(1))=rule;% vector of 1st rule
    
% Check if this rule is covered in Gpos table
    if ismember(rule,G_pos(:,sort_id(1)),'rows') % if rule is covered
        % add more rules and check again
        for j=2:k % next highest value
            if ac_neg_sim_measure(i,sort_id(j))==0
                break % stop
            else % create new rule
                new_rule=G_neg(i,sort_id(j));
                rule_vec(sort_id(j))=new_rule;
                ne_index=rule_vec~=-5555;
                ne_rule=rule_vec(1,ne_index);
                                                    
                if ismember(ne_rule,G_pos(:,ne_index),'rows')
                   continue
                else
                    break % accept rule
                end
            end
        end
    end 
    set_of_neg_rules=[set_of_neg_rules;rule_vec];
end

set_of_unique_neg_rules=unique(set_of_neg_rules,'rows');
[n_unq_rules,~]=size(set_of_unique_neg_rules);

% Check how many instances each rule covered
for i=1:n_unq_rules
    ne_rules=sum(set_of_unique_neg_rules(i,:)~=-5555);
    for ki=1:Nd_neg
        nmatch_index= neg_table(ki,:)==set_of_unique_neg_rules(i,:);
        if sum(nmatch_index)==ne_rules
            match_count(ki,1)=1;
             neg_bags_matched(ki,1)=neg_tab_bag_tag(ki);
        end
    end
     neg_bag_match_cell{i,1}=unique(nonzeros(neg_bags_matched));
    neg_bags_matched=[];
    nmatch(i,1)=sum(match_count);
    match_count=[];
end
R_neg_table=[set_of_unique_neg_rules,nmatch];

% Step 5: Similarity matrix M

M=zeros(nunq_bags,nunq_bags);
[n_inst,~]=size(x);
[n_unq_pos_rules,~]=size(set_of_unique_pos_rules);
[n_unq_neg_rules,~]=size(set_of_unique_neg_rules);
R_pos_neg=[R_pos_table(:,1:end-1);R_neg_table(:,1:end-1)];
pos_neg_bag_match_cell=[pos_bag_match_cell;neg_bag_match_cell];
M_store=M;

for i=1:n_inst
    inst_bag_id=x(i,1); % How many bags for the selected instance
    
    % Compare instance against pos rules
    for j=1:(n_unq_pos_rules+n_unq_neg_rules)
        match_oye=x(i,2:end-1)==R_pos_neg(j,:);
        ne_rules=sum(R_pos_neg(j,:)~=-5555,2);
        if sum(match_oye)==ne_rules            
            matched_bags=pos_neg_bag_match_cell{j,1}';
            other_bag=inst_bag_id~=matched_bags;

          M(inst_bag_id,nonzeros(matched_bags.*other_bag))=1;
          M_store=M_store+M;
          M=zeros(nunq_bags,nunq_bags);%reset to zeros
        end
    end

end

% Step 6: Making similarity matrix for the test bag
[filename,pathname]=uigetfile('.xls','Select test data.');

full_fn=strcat(pathname,filename);
y=xlsread(full_fn);

[n_inst,~]=size(y);

M_row=zeros(1,nunq_bags);
M_row_store=M_row;

for i=1:n_inst
   
    % Compare instance against pos rules
    for j=1:(n_unq_pos_rules+n_unq_neg_rules)
        match_oye=x(i,2:end-1)==R_pos_neg(j,:);
        ne_rules=sum(R_pos_neg(j,:)~=-5555,2);
        if sum(match_oye)==ne_rules            
            matched_bags=pos_neg_bag_match_cell{j,1}';
            
          M_row(1,matched_bags)=1;
          M_row_store=M_row_store+M_row;
          M_row=zeros(1,nunq_bags);%reset to zeros
        end
    end

end

M_col_store=M_row_store';

M_store_final=[M_store;M_row_store];
M_store_final=[M_store_final,[M_col_store;NaN]];

% Step 7: Sorting results for references/Final classification 
[row_ord,ri]=sort(M_store_final(end,1:end-1),'descend');

Ref=11;

[unq_bag_tags,ui]=unique(x(:,1));
bag_class=x(ui,end)';

bag_ref=bag_class(ri);
pos_ref=sum(bag_ref(1:Ref)==1)
neg_ref=sum(bag_ref(1:Ref)==0)

if pos_ref>neg_ref
    classification=1; % Musk
else
    classification=0; % Non Musk
end
classification