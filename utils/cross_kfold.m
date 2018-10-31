function [best_parameters] = cross_kfold(model_class, parameters, folds, dataset)
    X = dataset(:,1:end-1);
    y = dataset(:,end);
    %% create all combinations of parameters
    parameter_names = fieldnames(parameters);
    if length(fieldnames(parameters)) > 1
        args = sprintf('%s%s', sprintf('parameters.%s, ',...
            parameter_names{1:end-1}), sprintf('parameters.%s',...
            parameter_names{end}));
    else
        args = sprintf('parameters.%s', parameter_names{1});
    end
    eval(sprintf('parameter_combination = combvec(%s)'';', args));
    %% LOOP of parameters
    [N, M] = size(parameter_combination);
    for i=1:N
        parameters_ = cell2struct(num2cell(parameter_combination(i,:)), parameter_names',2);
%         fprintf('\n        - ');
%         for j=1:length(parameter_names)
%             fprintf('%s: %f, ',parameter_names{j}, eval(sprintf('parameters_.%s',parameter_names{j})));
%         end
%         fprintf(' | fold: ');
        %% K-fold LOOP
        for k=1:length(folds)
%             fprintf('%d, ', k);

            clf = eval(sprintf('%s(parameters_);',model_class));
            clf.fit(X(folds{k}.train,:), y(folds{k}.train,:));
            y_hat  = clf.predict(X(folds{k}.test,:));
            mse(i,k) = mean((y_hat - y(folds{k}.test,:)).^2);
        end
%         fprintf(' (mse=%.3f), ', mean(mse(i,:)));
    end
    mean_mse = mean(mse,2);
    
    [~,best_i] = min(mean_mse);
    
    best_parameters = cell2struct(num2cell(parameter_combination(best_i,:)), parameter_names',2);
end