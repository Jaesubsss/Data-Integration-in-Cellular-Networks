%initCobraToolbox
% model setup
remodel = readCbModel('e_coli_core');
model = convertToIrreversible(remodel);
%model = changeObjective(model,'BIOMASS_Ecoli_core_w_GAM');
FBAsol = optimizeCbModel(model);

weight = zeros(length(model.grRules),1);
for i = 1:length(model.grRules)
    count = 0;
    entry = model.grRules{i,1};
    if numel(entry) ~= 0
        rules = strsplit(entry,'or');
        for j = 1:length(rules)
            countlist = zeros(1,length(rules));
            %countlist
            counts = strfind(rules{1,j}, 'and');
            count = length(counts) + 1;
            %count
            %j
            countlist(j) = count;
        end
        weight(i,1) = min(countlist);
    end
end


